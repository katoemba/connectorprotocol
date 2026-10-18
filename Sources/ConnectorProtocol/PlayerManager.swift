import Foundation
import Observation
import SwiftUI
import os.log

public final class AnyPlayerBrowser: Sendable {
    private let _controllerType: @Sendable () -> String
    private let _playerEventStream: @Sendable () -> AsyncStream<PlayerBrowserEvent>
    private let _startListening: @Sendable ([PlayerDefinition]) async -> Void
    private let _stopListening: @Sendable () async -> Void
    private let _decodePlayer: @Sendable (PlayerDefinition) async throws -> any PlayerProtocol
    private let _isManualPlayer: @Sendable (PlayerDefinition) -> Bool
    private let _playerRemoved: @Sendable (PlayerDefinition) -> Void

    public let browser: (any PlayerBrowserProtocol)
    public var controllerType: String { _controllerType() }
    public var playerEventStream: AsyncStream<PlayerBrowserEvent> { _playerEventStream() }

    public init<Browser: PlayerBrowserProtocol>(_ browser: Browser) {
        self.browser = browser
        _controllerType = { browser.controllerType }
        _playerEventStream = { browser.playerEventStream }
        _startListening = { predefinedPlayers in
            await browser.startListening(predefinedPlayers: predefinedPlayers)
        }
        _stopListening = {
            await browser.stopListening()
        }
        _decodePlayer = { definition in
            try await browser.decodePlayer(definition)
        }
        _isManualPlayer = { definition in
            browser.isManualPlayer(definition)
        }
        _playerRemoved = { definition in
            browser.playerRemoved(definition)
        }
    }

    public func startListening(predefinedPlayers: [PlayerDefinition]) async {
        await _startListening(predefinedPlayers)
    }

    public func stopListening() async {
        await _stopListening()
    }

    public func decodePlayer(_ playerDefinition: PlayerDefinition) async throws -> any PlayerProtocol {
        try await _decodePlayer(playerDefinition)
    }

    public func isManualPlayer(_ playerDefinition: PlayerDefinition) -> Bool {
        _isManualPlayer(playerDefinition)
    }

    public func playerRemoved(_ playerDefinition: PlayerDefinition) {
        _playerRemoved(playerDefinition)
    }
}

public struct ManagedPlayer: Identifiable, Equatable, Hashable {
    public let id: String
    public var definition: PlayerDefinition
    public var player: any PlayerProtocol
    public var isReachable: Bool
    public var isDetected: Bool
    public var lastSeen: Date
    private let _settingsView: (((any PlayerProtocol) -> Void)?, ((any PlayerProtocol) -> Void)?) -> AnyView

    public init(id: String,
                definition: PlayerDefinition,
                player: any PlayerProtocol,
                isReachable: Bool,
                isDetected: Bool,
                lastSeen: Date) {
        self.id = id
        self.definition = definition
        self.player = player
        self.isReachable = isReachable
        self.isDetected = isDetected
        self.lastSeen = lastSeen
        _settingsView = { deleteAction, hideAction in
            AnyView(player.settingsView(deleteAction: deleteAction,
                                        hideAction: hideAction))
        }
    }
    
    public static func == (lhs: ManagedPlayer, rhs: ManagedPlayer) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func settingsView(deleteAction: ((any PlayerProtocol) -> ())?,
                      hideAction: ((any PlayerProtocol) -> ())?) -> some View {
        _settingsView(deleteAction, hideAction)
    }

}

@Observable
@MainActor
public final class PlayerManager {
    static let logger = os.Logger(subsystem: "com.katoemba.connectorprotocol", category: "playermanager")

    public private(set) var players: [ManagedPlayer] = []
    public private(set) var isListening = false

    public let stalePlayerInterval: TimeInterval
    public let reachabilityRefreshInterval: TimeInterval

    public let browsers: [AnyPlayerBrowser]
    private let userDefaults: UserDefaults
    private let storageKey: String
    private var browserEventTasks: [String: Task<Void, Never>] = [:]
    private var reachabilityTask: Task<Void, Never>?

    /// The most recently requested lifecycle change (activate, deactivate, rediscover). The next one waits for it.
    private var lifecycleTail: Task<Void, Never>?
    private var scheduledDeactivation: Task<Void, Never>?

    /// Persisted players that could not be decoded/revived yet (e.g. an OpenHome device that did not answer
    /// its HTTP description request in time). They are retained so they are neither lost from persistence nor
    /// forgotten, and are retried on every reachability cycle until the device becomes available.
    private var unrevivedPlayers: [PersistedPlayer] = []
    private var isReviving = false

    /// When false, persisted non-manual players are not restored at startup and only found through live
    /// discovery. Manual players are always restored.
    public let restoreCachedPlayers: Bool

    /// Persisted non-manual players deliberately not restored (see `restoreCachedPlayers`). They are kept in
    /// persistence, so re-enabling the setting brings them back, until they go stale or are discovered live.
    private var dormantPlayers: [PersistedPlayer] = []

    /// Persisted players that activate() is still restoring. Until then they only exist in storage, so they are
    /// written back whenever the state is persisted, for example when a browser announces a player halfway
    /// through the restore. Otherwise a crash at that moment would lose every player not restored yet.
    private var restoringPlayers: [PersistedPlayer] = []

    #if os(iOS)
    private var lifecycleObservers: [NSObjectProtocol] = []
    #endif

    public init(browsers: [AnyPlayerBrowser],
                userDefaults: UserDefaults = .standard,
                userDefaultsKey: String = "ConnectorProtocol.PlayerManager.v1",
                stalePlayerInterval: TimeInterval = 14 * 24 * 60 * 60,
                reachabilityRefreshInterval: TimeInterval = 5.0,
                restoreCachedPlayers: Bool = true) {
        self.restoreCachedPlayers = restoreCachedPlayers
        self.browsers = browsers
        self.userDefaults = userDefaults
        self.storageKey = userDefaultsKey
        self.stalePlayerInterval = stalePlayerInterval
        self.reachabilityRefreshInterval = max(1.0, reachabilityRefreshInterval)
    }

    // MARK: - Lifecycle

    public func activate(selectedPlayerID: String?) async {
        cancelScheduledDeactivation()
        await runExclusively {
            await self.performActivate(selectedPlayerID: selectedPlayerID)
        }
    }

    /// Forget all loaded players and start over: persisted players are restored again and the browsers search the
    /// network afresh. Unlike a plain deactivate/activate cycle, this visibly rebuilds the list.
    public func rediscover(selectedPlayerID: String?) async {
        cancelScheduledDeactivation()
        await runExclusively {
            await self.performDeactivate()
            self.players.removeAll()
            self.unrevivedPlayers.removeAll()
            await self.performActivate(selectedPlayerID: selectedPlayerID)
        }
    }

    public func deactivate() async {
        await runExclusively {
            await self.performDeactivate()
        }
    }

    /// Deactivates after `delay` seconds, unless `activate` or `cancelScheduledDeactivation` is called first.
    func scheduleDeactivation(after delay: TimeInterval) {
        scheduledDeactivation?.cancel()
        scheduledDeactivation = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(delay, 0) * 1_000_000_000))
            guard !Task.isCancelled, let self else { return }
            self.scheduledDeactivation = nil
            await self.deactivate()
        }
    }

    func cancelScheduledDeactivation() {
        scheduledDeactivation?.cancel()
        scheduledDeactivation = nil
    }

    /// Lifecycle changes run one at a time, in the order they were requested. Otherwise a deactivate that arrives
    /// while a slow activate is still restoring players would be overtaken by it, leaving the browsers running.
    private func runExclusively(_ operation: @escaping @MainActor () async -> Void) async {
        let previous = lifecycleTail
        let task = Task { @MainActor in
            await previous?.value
            await operation()
        }
        lifecycleTail = task
        await task.value
    }

    private func performActivate(selectedPlayerID: String?) async {
        Self.logger.debug("Initializing")
        if isListening {
            return
        }

        isListening = true
        startBrowserEventSubscriptions()
        Self.logger.debug("EventSubscriptions started")

        var state = loadState()
        if state.formatVersion < PersistedState.currentFormatVersion {
            upgradeManualFlags(in: &state)
        }
        restoringPlayers = state.players

        let now = Date()
        // Manual players can't be rediscovered, so they never go stale.
        state.players.removeAll {
            !$0.definition.isManual && now.timeIntervalSince($0.lastSeen) > stalePlayerInterval
        }

        // The browsers announce these again, which tells them which of the cached players are actually there.
        let predefinedPlayers = state.players.map(\.definition).filter { restoreCachedPlayers || $0.isManual }

        // On a re-activation (e.g. returning to the app) the loaded players are kept, so the list doesn't empty
        // out and players in use aren't replaced by new objects. Only missing ones are restored.
        let loadedKeys = Set(players.map(\.id))
        var toRestore = state.players.filter { !loadedKeys.contains(Self.playerKey(for: $0.definition)) }
        unrevivedPlayers.removeAll()
        dormantPlayers.removeAll()

        if !restoreCachedPlayers {
            dormantPlayers = toRestore.filter { !$0.definition.isManual }
            toRestore.removeAll { !$0.definition.isManual }
        }
        restoringPlayers = toRestore

        // The selected player first, so the app can select it right away.
        if let selectedPlayerID,
           let index = toRestore.firstIndex(where: { Self.playerKey(for: $0.definition) == selectedPlayerID }) {
            let selected = toRestore.remove(at: index)
            let decoded = try? await decodePlayer(from: selected.definition)
            restorePlayer(selected, decoded: decoded)
        }
        Self.logger.debug("Selected player \(selectedPlayerID ?? "none") restored")

        // Start discovery before restoring the rest: decoding a cached player may take a while (OpenHome needs a
        // network round trip), and that must not hold up the discovery of new players.
        await startBrowsersListening(predefinedPlayers: predefinedPlayers)
        Self.logger.debug("Browsers are listening")

        startReachabilityRefreshLoop()

        let remaining = toRestore
        let browsers = self.browsers
        await withTaskGroup(of: (PersistedPlayer, (any PlayerProtocol)?).self) { group in
            for persisted in remaining {
                group.addTask {
                    (persisted, try? await Self.decodePlayer(from: persisted.definition, using: browsers))
                }
            }
            for await (persisted, decoded) in group {
                restorePlayer(persisted, decoded: decoded)
            }
        }
        Self.logger.debug("Players restored from persistence")

        restoringPlayers.removeAll()
        removeStalePlayers(referenceDate: now)
        persistState()
    }

    private func performDeactivate() async {
        if !isListening {
            return
        }

        // The event tasks are kept running: a browser's event stream is created once, and cancelling the task
        // that iterates it terminates the stream for good, so a later activate() would never see any event.
        reachabilityTask?.cancel()
        reachabilityTask = nil

        await stopBrowsersListening()
        isListening = false
        persistState()
    }

    public func addManualPlayer(_ definition: PlayerDefinition) async throws {
        let player = try await decodePlayer(from: definition)
        let key = Self.playerKey(for: definition)
        upsertPlayer(player,
                     definition: definition,
                     key: key,
                     isDetected: false,
                     lastSeen: Date())
        await refreshReachability(for: key)
        removeStalePlayers(referenceDate: Date())
        persistState()
    }

    public func addManualPlayer(_ player: any PlayerProtocol) {
        let definition = makeDefinition(for: player)
        let key = Self.playerKey(for: definition)
        upsertPlayer(player,
                     definition: definition,
                     key: key,
                     isDetected: false,
                     lastSeen: Date())
        persistState()
        Task { @MainActor in
            await self.refreshReachability(for: key)
            self.persistState()
        }
    }

    public func removePlayer(id: String) {
        let definition = players.first(where: { $0.id == id })?.definition
            ?? (restoringPlayers + unrevivedPlayers + dormantPlayers).first(where: { Self.playerKey(for: $0.definition) == id })?.definition
        if let definition {
            for browser in browsers where browser.controllerType == definition.type {
                browser.playerRemoved(definition)
            }
        }

        players.removeAll(where: { $0.id == id })
        unrevivedPlayers.removeAll { Self.playerKey(for: $0.definition) == id }
        dormantPlayers.removeAll { Self.playerKey(for: $0.definition) == id }
        restoringPlayers.removeAll { Self.playerKey(for: $0.definition) == id }
        persistState()
    }

    #if os(iOS)
    public func startApplicationLifecycleMonitoring(notificationCenter: NotificationCenter = .default, selectedPlayerIDDefaultKey: String) {
        guard lifecycleObservers.isEmpty else {
            return
        }

        let activateObserver = notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                              object: nil,
                                                              queue: nil) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                // Also cancels a deactivation scheduled by a short interruption (Control Center, a system alert).
                await self.activate(selectedPlayerID: self.userDefaults.string(forKey: selectedPlayerIDDefaultKey))
            }
        }

        let deactivateObserver = notificationCenter.addObserver(forName: UIApplication.willResignActiveNotification,
                                                                object: nil,
                                                                queue: nil) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                // Wait 5 seconds before deactivating, to allow playqueue commands to complete
                self.scheduleDeactivation(after: 5)
            }
        }

        lifecycleObservers = [activateObserver, deactivateObserver]

        if UIApplication.shared.applicationState == .active {
            Task { @MainActor in
                await self.activate(selectedPlayerID: self.userDefaults.string(forKey: selectedPlayerIDDefaultKey))
            }
        }
    }

    public func stopApplicationLifecycleMonitoring(notificationCenter: NotificationCenter = .default) {
        for observer in lifecycleObservers {
            notificationCenter.removeObserver(observer)
        }
        lifecycleObservers.removeAll()
    }
    #endif

    private func startBrowsersListening(predefinedPlayers: [PlayerDefinition]) async {
        for browser in browsers {
            await browser.startListening(predefinedPlayers: predefinedPlayers)
        }
    }

    private func stopBrowsersListening() async {
        for browser in browsers {
            await browser.stopListening()
        }
    }

    private func startBrowserEventSubscriptions() {
        for (index, browser) in browsers.enumerated() {
            let taskKey = "\(browser.controllerType)::\(index)"
            if browserEventTasks[taskKey] != nil {
                continue
            }
            browserEventTasks[taskKey] = Task { [weak self] in
                guard let self else { return }
                for await event in browser.playerEventStream {
                    if Task.isCancelled {
                        return
                    }
                    await self.handleBrowserEvent(event)
                }
            }
        }
    }

    private func startReachabilityRefreshLoop() {
        reachabilityTask?.cancel()
        reachabilityTask = Task { [weak self] in
            guard let self else { return }

            // The first round comes after one interval: players are pinged when they are restored or announced,
            // so pinging them all again right away only adds to the traffic at start-up.
            let sleepNanos = UInt64(self.reachabilityRefreshInterval * 1_000_000_000)
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: sleepNanos)
                guard !Task.isCancelled else { return }

                // Reviving can take a while (network round trips, timeouts for devices that are off), so it runs
                // on its own, and the pings don't wait for it.
                if !self.isReviving {
                    Task { @MainActor [weak self] in
                        await self?.reviveUnrevivedPlayers()
                    }
                }
                self.refreshDefinitions()
                await self.refreshReachabilityForAllPlayers()
            }
        }
    }

    private func handleBrowserEvent(_ event: PlayerBrowserEvent) async {
        let now = Date()

        switch event {
        case .added(let player), .updated(let player):
            let definition = makeDefinition(for: player)
            let key = Self.playerKey(for: definition)
            if case .updated = event {
                // An explicit update (e.g. a manually added player) replaces any existing entry with the
                // same key, instead of keeping the previously detected player object and its settings.
                players.removeAll { $0.id == key }
            }
            // The player has now been discovered for real, so it no longer needs to be revived from persistence.
            unrevivedPlayers.removeAll { Self.playerKey(for: $0.definition) == key }
            dormantPlayers.removeAll { Self.playerKey(for: $0.definition) == key }
            let existing = players.first(where: { $0.id == key })
            upsertPlayer(player,
                         definition: definition,
                         key: key,
                         isDetected: true,
                         lastSeen: now)
            // Not awaited: a ping can take seconds, and the events that follow shouldn't wait for it.
            if let existing, existing.player !== player, !existing.isReachable {
                replaceInBackground(key: key, current: existing.player, with: player)
            }
            else {
                refreshReachabilityInBackground(for: key)
            }

        case .removed(let uniqueID):
            if let index = players.firstIndex(where: { $0.id == uniqueID }) {
                // It was there until now: it only goes stale if it isn't seen again for a while from here.
                players[index].isDetected = false
                players[index].lastSeen = now
            }
        }

        removeStalePlayers(referenceDate: now)
        persistState()
    }

    /// State written before `PlayerDefinition.isManual` existed doesn't say which players are manual. That is
    /// recorded in the type specific data, so ask the browsers. Without this, manual players that haven't been seen
    /// for a while would be purged as stale, or taken for cached players, by the first launch after an update.
    /// This must stay cheap, as it holds up the first launch after an update: the browsers only look at the
    /// definition, they don't decode players (which for some connectors means talking to the device).
    private func upgradeManualFlags(in state: inout PersistedState) {
        for index in state.players.indices where !state.players[index].definition.isManual {
            let definition = state.players[index].definition
            if browsers.contains(where: { $0.controllerType == definition.type && $0.isManualPlayer(definition) }) {
                state.players[index].definition.isManual = true
            }
        }
    }

    /// Put a persisted player in the list, or keep it for a retry when it could not be decoded.
    private func restorePlayer(_ persisted: PersistedPlayer, decoded: (any PlayerProtocol)?) {
        let key = Self.playerKey(for: persisted.definition)

        // Gone from restoringPlayers means it was removed by the user while it was being restored.
        guard restoringPlayers.contains(where: { Self.playerKey(for: $0.definition) == key }) else {
            return
        }
        restoringPlayers.removeAll { Self.playerKey(for: $0.definition) == key }

        // A browser may have announced the player while it was being restored, which is more recent information.
        // Except when the stored player is a manual one and the announced one is not: discovery found the same
        // host and port, but doesn't know it was added manually, nor the settings that came with it.
        if let index = players.firstIndex(where: { $0.id == key }) {
            if persisted.definition.isManual && !players[index].definition.isManual {
                players[index].definition = persisted.definition
            }
            return
        }

        guard let decoded else {
            // Revival failed (e.g. an OpenHome device that did not answer in time). Retain the persisted
            // definition so it stays in persistence and is retried, instead of being lost forever.
            unrevivedPlayers.append(persisted)
            Self.logger.debug("Could not revive player \(persisted.definition.name) yet, will retry")
            return
        }

        upsertPlayer(decoded,
                     definition: persisted.definition,
                     key: key,
                     isDetected: false,
                     lastSeen: persisted.lastSeen)
        refreshReachabilityInBackground(for: key)
    }

    private func decodePlayer(from definition: PlayerDefinition) async throws -> any PlayerProtocol {
        try await Self.decodePlayer(from: definition, using: browsers)
    }

    /// Not main actor isolated, so that several players can be decoded concurrently.
    private nonisolated static func decodePlayer(from definition: PlayerDefinition,
                                                 using browsers: [AnyPlayerBrowser]) async throws -> any PlayerProtocol {
        let preferred = browsers.filter { $0.controllerType == definition.type }
        let fallback = browsers.filter { $0.controllerType != definition.type }

        for browser in preferred + fallback {
            if let decoded = try? await browser.decodePlayer(definition) {
                return decoded
            }
        }

        throw PlayerManagerError.unableToDecodePlayer(definition)
    }

    private func refreshReachabilityForAllPlayers() async {
        // All at once: a player that doesn't answer takes seconds to time out, and the others shouldn't wait for it.
        let keys = players.map(\.id)
        let refreshes = keys.map { key in
            Task { @MainActor in
                await self.refreshReachability(for: key)
            }
        }
        for refresh in refreshes {
            await refresh.value
        }
    }

    /// The list keeps the object it already has when a player is announced again. But when that object can't reach
    /// the player (e.g. it was restored with an address that is no longer valid) and the newly announced one can,
    /// switch to the new one: it carries the connection details discovery just worked out.
    private func replaceInBackground(key: String, current: any PlayerProtocol, with candidate: any PlayerProtocol) {
        Task { @MainActor [weak self] in
            async let currentAnswers = Task.detached { await current.ping() }.value
            async let candidateAnswers = Task.detached { await candidate.ping() }.value
            let (currentIsReachable, candidateIsReachable) = await (currentAnswers, candidateAnswers)

            guard let self, let index = self.players.firstIndex(where: { $0.id == key }) else { return }
            let entry = self.players[index]
            guard entry.player === current else { return }

            if !currentIsReachable && candidateIsReachable {
                // The new object carries what discovery just worked out (e.g. a new address), which is what has to
                // be restored at the next launch. A manual player keeps its own definition, with its manual settings.
                var definition = entry.definition
                if !definition.isManual {
                    let candidateDefinition = self.makeDefinition(for: candidate)
                    if Self.playerKey(for: candidateDefinition) == entry.id {
                        definition = candidateDefinition
                    }
                }
                self.players[index] = ManagedPlayer(id: entry.id,
                                                    definition: definition,
                                                    player: candidate,
                                                    isReachable: true,
                                                    isDetected: entry.isDetected,
                                                    lastSeen: Date())
                Self.logger.debug("Replaced unreachable player \(entry.definition.name) by the one just found")
                self.persistState()
            }
            else {
                self.players[index].isReachable = currentIsReachable
                if currentIsReachable {
                    self.players[index].lastSeen = Date()
                }
            }
        }
    }

    private func refreshReachabilityInBackground(for key: String) {
        Task { @MainActor [weak self] in
            await self?.refreshReachability(for: key)
        }
    }

    private func refreshReachability(for key: String) async {
        guard let player = players.first(where: { $0.id == key })?.player else {
            return
        }

        let isReachable = await Task.detached { await player.ping() }.value
        // The entry may have switched to another object while pinging (see replaceInBackground); this answer is
        // about the old one.
        guard let index = players.firstIndex(where: { $0.id == key }), players[index].player === player else {
            return
        }

        players[index].isReachable = isReachable
        if isReachable {
            players[index].lastSeen = Date()
        }
    }

    /// A player's definition is what gets restored at the next launch. Settings the user changes on the player itself
    /// (e.g. its type) end up in the player's own definition, and players don't report that, so pick it up here.
    /// Otherwise a manual player, which is only announced once per launch, restores with the old settings.
    private func refreshDefinitions() {
        var changed = false
        for index in players.indices {
            let current = players[index].definition
            guard let definition = try? players[index].player.playerDefinition(),
                  definition.id == players[index].id,
                  definition.typeSpecificData != current.typeSpecificData || definition.name != current.name else {
                continue
            }
            // A discovered object standing in for a manual player doesn't carry the manual settings.
            guard definition.isManual || !current.isManual else {
                continue
            }
            players[index].definition = definition
            changed = true
        }
        if changed {
            persistState()
        }
    }

    private func removeStalePlayers(referenceDate: Date) {
        players.removeAll {
            !($0.isDetected) && !$0.definition.isManual && referenceDate.timeIntervalSince($0.lastSeen) > stalePlayerInterval
        }
    }

    private func upsertPlayer(_ player: any PlayerProtocol,
                              definition: PlayerDefinition,
                              key: String,
                              isDetected: Bool,
                              lastSeen: Date) {
        // Already on the main actor: mutate synchronously so callers that immediately follow with
        // `refreshReachability(for:)` observe the inserted player rather than racing a deferred block.
        if let index = players.firstIndex(where: { $0.id == key }) {
            // A discovered player with the same key must not replace a manual definition: that would lose the
            // manual flag and the user's settings (e.g. password), which discovery doesn't know about.
            if !(players[index].definition.isManual && !definition.isManual) {
                players[index].definition = definition
            }
            players[index].isDetected = isDetected
            players[index].lastSeen = max(players[index].lastSeen, lastSeen)
            players[index].player.updateVersion(player.version)
        } else {
            players.append(ManagedPlayer(id: key,
                                         definition: definition,
                                         player: player,
                                         isReachable: false,
                                         isDetected: isDetected,
                                         lastSeen: lastSeen))
            players.sort(by: { $0.player.name < $1.player.name })
        }
    }

    private func persistState() {
        var persistedPlayers = players.map { persistedPlayer in
            PersistedPlayer(definition: persistedPlayer.definition,
                            lastSeen: persistedPlayer.lastSeen)
        }
        var persistedKeys = Set(players.map(\.id))

        // Keep players that are not in the list (yet): the ones still being restored, and the ones that could not
        // be revived (typically OpenHome), so a temporarily unreachable player is not erased from persistence.
        for pending in restoringPlayers + unrevivedPlayers {
            if persistedKeys.insert(Self.playerKey(for: pending.definition)).inserted {
                persistedPlayers.append(pending)
            }
        }

        // Keep cached players that were deliberately not restored, unless they went stale or are live now.
        let now = Date()
        for dormant in dormantPlayers where now.timeIntervalSince(dormant.lastSeen) <= stalePlayerInterval {
            if persistedKeys.insert(Self.playerKey(for: dormant.definition)).inserted {
                persistedPlayers.append(dormant)
            }
        }

        let state = PersistedState(players: persistedPlayers)

        if let data = try? JSONEncoder().encode(state) {
            userDefaults.set(data, forKey: storageKey)
        }
    }

    /// Retry decoding/reviving any persisted players that could not be revived earlier. Devices such as
    /// OpenHome players only decode successfully once they answer their HTTP description request, which may
    /// happen seconds after launch. This is invoked from the reachability refresh loop.
    private func reviveUnrevivedPlayers() async {
        let pendingPlayers = unrevivedPlayers
        let browsers = self.browsers
        guard !pendingPlayers.isEmpty, !isReviving else {
            return
        }
        isReviving = true
        defer { isReviving = false }

        // All at once: each one that is still unreachable takes a timeout.
        let decodedPlayers = await withTaskGroup(of: (PersistedPlayer, (any PlayerProtocol)?).self) { group in
            for pending in pendingPlayers {
                group.addTask {
                    (pending, try? await Self.decodePlayer(from: pending.definition, using: browsers))
                }
            }
            var results: [(PersistedPlayer, (any PlayerProtocol)?)] = []
            for await result in group {
                results.append(result)
            }
            return results
        }

        var revivedKeys = Set<String>()
        for (pending, decoded) in decodedPlayers {
            let key = Self.playerKey(for: pending.definition)
            guard let player = decoded else {
                continue
            }

            // While decoding, the player may have been removed by the user, or announced by a browser.
            guard unrevivedPlayers.contains(where: { Self.playerKey(for: $0.definition) == key }) else {
                continue
            }

            upsertPlayer(player,
                         definition: pending.definition,
                         key: key,
                         isDetected: false,
                         lastSeen: pending.lastSeen)
            revivedKeys.insert(key)
            refreshReachabilityInBackground(for: key)
            Self.logger.debug("Revived previously unreachable player \(pending.definition.name)")
        }

        if !revivedKeys.isEmpty {
            unrevivedPlayers.removeAll { revivedKeys.contains(Self.playerKey(for: $0.definition)) }
            persistState()
        }
    }

    private func loadState() -> PersistedState {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return PersistedState(players: [])
        }
        guard let state = try? JSONDecoder().decode(PersistedState.self, from: data) else {
            // Unreadable as a whole: keep a copy, because the next persistState() would overwrite it with an
            // empty list and lose every player (manual ones can't be rediscovered).
            let backupKey = storageKey + ".unreadable"
            if userDefaults.data(forKey: backupKey) == nil {
                userDefaults.set(data, forKey: backupKey)
            }
            Self.logger.error("Could not decode persisted players, backed up under \(backupKey)")
            return PersistedState(players: [])
        }
        return state
    }

    private func makeDefinition(for player: any PlayerProtocol) -> PlayerDefinition {
        if let playerDefinition = try? player.playerDefinition() {
            return playerDefinition
        }

        return PlayerDefinition(id: player.uniqueID,
                                name: player.name,
                                type: player.controllerType,
                                typeSpecificData: Data())
    }

    private static func playerKey(for definition: PlayerDefinition) -> String {
        definition.id
    }
}

public enum PlayerManagerError: Error {
    case unableToDecodePlayer(PlayerDefinition)
}

private struct PersistedPlayer: Codable {
    var definition: PlayerDefinition
    var lastSeen: Date
}

private struct PersistedState: Codable {
    /// 1: players only (no format version). 2: `PlayerDefinition.isManual` is recorded.
    static let currentFormatVersion = 2

    var formatVersion: Int
    var players: [PersistedPlayer]

    init(players: [PersistedPlayer]) {
        self.formatVersion = Self.currentFormatVersion
        self.players = players
    }

    private enum CodingKeys: String, CodingKey {
        case formatVersion, players
    }

    private struct Skip: Decodable {
        init(from decoder: Decoder) throws {}
    }

    // Decode entries one by one, so a single unreadable player doesn't discard all the others.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        formatVersion = (try? container.decodeIfPresent(Int.self, forKey: .formatVersion)) ?? 1
        var list = try container.nestedUnkeyedContainer(forKey: .players)
        var decoded: [PersistedPlayer] = []
        while !list.isAtEnd {
            if let player = try? list.decode(PersistedPlayer.self) {
                decoded.append(player)
            } else {
                _ = try? list.decode(Skip.self)
            }
        }
        players = decoded
    }
}
