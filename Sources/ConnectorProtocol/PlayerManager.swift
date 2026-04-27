import Foundation
import Observation

#if os(iOS)
import UIKit
#endif

public final class AnyPlayerBrowser {
    private let _controllerType: () -> String
    private let _playerEventStream: () -> AsyncStream<PlayerBrowserEvent>
    private let _startListening: ([PlayerDefinition]) async -> Void
    private let _stopListening: () async -> Void
    private let _decodePlayer: (PlayerDefinition) async throws -> any PlayerProtocol

    public var controllerType: String { _controllerType() }
    public var playerEventStream: AsyncStream<PlayerBrowserEvent> { _playerEventStream() }

    public init<Browser: PlayerBrowserProtocol>(_ browser: Browser) {
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
}

public struct ManagedPlayer: Identifiable {
    public let id: String
    public var definition: PlayerDefinition
    public var player: any PlayerProtocol
    public var isReachable: Bool
    public var isDetected: Bool
    public var lastSeen: Date

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
    }
}

public struct PlayerManagerDiagnostics: Sendable {
    public struct Entry: Sendable {
        public let key: String
        public let definition: PlayerDefinition
        public let lastSeen: Date
        public let isDetected: Bool

        public init(key: String, definition: PlayerDefinition, lastSeen: Date, isDetected: Bool) {
            self.key = key
            self.definition = definition
            self.lastSeen = lastSeen
            self.isDetected = isDetected
        }
    }

    public let selectedPlayerKey: String?
    public let entries: [Entry]

    public init(selectedPlayerKey: String?, entries: [Entry]) {
        self.selectedPlayerKey = selectedPlayerKey
        self.entries = entries
    }
}

@MainActor
@Observable
public final class PlayerManager {
    public private(set) var players: [ManagedPlayer] = []
    public private(set) var isListening = false
    public private(set) var selectedPlayerID: String?

    public var selectedPlayer: (any PlayerProtocol)? {
        guard let selectedPlayerID else {
            return nil
        }
        return players.first(where: { $0.id == selectedPlayerID })?.player
    }

    public let stalePlayerInterval: TimeInterval
    public let reachabilityRefreshInterval: TimeInterval

    private let browsers: [AnyPlayerBrowser]
    private let userDefaults: UserDefaults
    private let storageKey: String
    private var browserEventTasks: [String: Task<Void, Never>] = [:]
    private var reachabilityTask: Task<Void, Never>?

    #if os(iOS)
    private var lifecycleObservers: [NSObjectProtocol] = []
    #endif

    public init(browsers: [AnyPlayerBrowser],
                userDefaults: UserDefaults = .standard,
                userDefaultsKey: String = "ConnectorProtocol.PlayerManager.v1",
                stalePlayerInterval: TimeInterval = 14 * 24 * 60 * 60,
                reachabilityRefreshInterval: TimeInterval = 5.0) {
        self.browsers = browsers
        self.userDefaults = userDefaults
        self.storageKey = userDefaultsKey
        self.stalePlayerInterval = stalePlayerInterval
        self.reachabilityRefreshInterval = max(1.0, reachabilityRefreshInterval)
    }

    public func activate() async {
        if isListening {
            return
        }

        isListening = true
        startBrowserEventSubscriptions()

        await restorePlayersFromPersistence()
        await startBrowsersListening()
        //await ingestCurrentBrowserPlayers()
        startReachabilityRefreshLoop()
    }

    public func deactivate() async {
        if !isListening {
            return
        }

        for task in browserEventTasks.values {
            task.cancel()
        }
        browserEventTasks.removeAll()
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
        players.removeAll(where: { $0.id == id })
        if selectedPlayerID == id {
            selectedPlayerID = nil
        }
        persistState()
    }

    public func selectPlayer(id: String?) {
        selectedPlayerID = id
        persistState()
        if let id {
            Task { @MainActor in
                await self.refreshReachability(for: id)
                self.persistState()
            }
        }
    }

    public func diagnostics() -> PlayerManagerDiagnostics {
        let persisted = loadState()
        let entries = persisted.players.map { persistedEntry in
            let key = Self.playerKey(for: persistedEntry.definition)
            let isDetected = players.first(where: { $0.id == key })?.isDetected ?? false
            return PlayerManagerDiagnostics.Entry(key: key,
                                                  definition: persistedEntry.definition,
                                                  lastSeen: persistedEntry.lastSeen,
                                                  isDetected: isDetected)
        }

        return PlayerManagerDiagnostics(selectedPlayerKey: persisted.selectedPlayerKey,
                                        entries: entries)
    }

    #if os(iOS)
    public func startApplicationLifecycleMonitoring(notificationCenter: NotificationCenter = .default) {
        guard lifecycleObservers.isEmpty else {
            return
        }

        let activateObserver = notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                              object: nil,
                                                              queue: nil) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.activate()
            }
        }

        let deactivateObserver = notificationCenter.addObserver(forName: UIApplication.willResignActiveNotification,
                                                                object: nil,
                                                                queue: nil) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.deactivate()
            }
        }

        lifecycleObservers = [activateObserver, deactivateObserver]

        if UIApplication.shared.applicationState == .active {
            Task { @MainActor in
                await self.activate()
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

    private func startBrowsersListening() async {
        let predefinedPlayers = loadState().players.map(\.definition)
        for browser in browsers {
            await browser.startListening(predefinedPlayers: predefinedPlayers)
        }
    }

    private func stopBrowsersListening() async {
        for browser in browsers {
            await browser.stopListening()
        }
    }

//    private func ingestCurrentBrowserPlayers() async {
//        let now = Date()
//        for browser in browsers {
//            for player in browser.players {
//                let definition = makeDefinition(for: player)
//                let key = Self.playerKey(for: definition)
//                upsertPlayer(player,
//                             definition: definition,
//                             key: key,
//                             isDetected: true,
//                             lastSeen: now)
//                await refreshReachability(for: key)
//            }
//        }
//
//        removeStalePlayers(referenceDate: now)
//        persistState()
//    }

    private func startBrowserEventSubscriptions() {
        for (index, browser) in browsers.enumerated() {
            let taskKey = "\(browser.controllerType)::\(index)"
            browserEventTasks[taskKey]?.cancel()
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

            while !Task.isCancelled {
                await self.refreshReachabilityForAllPlayers()
                let sleepNanos = UInt64(self.reachabilityRefreshInterval * 1_000_000_000)
                try? await Task.sleep(nanoseconds: sleepNanos)
            }
        }
    }

    private func handleBrowserEvent(_ event: PlayerBrowserEvent) async {
        let now = Date()

        switch event {
        case .added(let player), .updated(let player):
            let definition = makeDefinition(for: player)
            let key = Self.playerKey(for: definition)
            upsertPlayer(player,
                         definition: definition,
                         key: key,
                         isDetected: true,
                         lastSeen: now)
            await refreshReachability(for: key)

        case .removed(let uniqueID):
            if let index = players.firstIndex(where: { $0.id == uniqueID }) {
                players[index].isDetected = false
            }
        }

        removeStalePlayers(referenceDate: now)
        persistState()
    }

    private func restorePlayersFromPersistence() async {
        var state = loadState()
        let now = Date()

        state.players.removeAll {
            now.timeIntervalSince($0.lastSeen) > stalePlayerInterval
        }

        players.removeAll()
        selectedPlayerID = nil

        if let selectedKey = state.selectedPlayerKey,
           let selectedPersisted = state.players.first(where: { Self.playerKey(for: $0.definition) == selectedKey }),
           let selectedPlayer = try? await decodePlayer(from: selectedPersisted.definition) {
            upsertPlayer(selectedPlayer,
                         definition: selectedPersisted.definition,
                         key: selectedKey,
                         isDetected: false,
                         lastSeen: selectedPersisted.lastSeen)
            selectedPlayerID = selectedKey
            await refreshReachability(for: selectedKey)
        }

        for persisted in state.players {
            let key = Self.playerKey(for: persisted.definition)
            if key == selectedPlayerID {
                continue
            }

            guard let restoredPlayer = try? await decodePlayer(from: persisted.definition) else {
                continue
            }

            upsertPlayer(restoredPlayer,
                         definition: persisted.definition,
                         key: key,
                         isDetected: false,
                         lastSeen: persisted.lastSeen)
            await refreshReachability(for: key)
        }

        removeStalePlayers(referenceDate: now)
        persistState()
    }

    private func decodePlayer(from definition: PlayerDefinition) async throws -> any PlayerProtocol {
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
        let keys = players.map(\.id)
        for key in keys {
            await refreshReachability(for: key)
        }
    }

    private func refreshReachability(for key: String) async {
        guard let index = players.firstIndex(where: { $0.id == key }) else {
            return
        }

        let isReachable = await players[index].player.ping()
        players[index].isReachable = isReachable
    }

    private func removeStalePlayers(referenceDate: Date) {
        players.removeAll {
            !($0.isDetected) && referenceDate.timeIntervalSince($0.lastSeen) > stalePlayerInterval
        }

        if let selectedPlayerID,
           !players.contains(where: { $0.id == selectedPlayerID }) {
            self.selectedPlayerID = nil
        }
    }

    private func upsertPlayer(_ player: any PlayerProtocol,
                              definition: PlayerDefinition,
                              key: String,
                              isDetected: Bool,
                              lastSeen: Date) {
        if let index = players.firstIndex(where: { $0.id == key }) {
            players[index].player = player
            players[index].definition = definition
            players[index].isDetected = isDetected
            players[index].lastSeen = max(players[index].lastSeen, lastSeen)
        } else {
            players.append(ManagedPlayer(id: key,
                                         definition: definition,
                                         player: player,
                                         isReachable: false,
                                         isDetected: isDetected,
                                         lastSeen: lastSeen))
        }
    }

    private func persistState() {
        let state = PersistedState(selectedPlayerKey: selectedPlayerID,
                                   players: players.map { persistedPlayer in
            PersistedPlayer(definition: persistedPlayer.definition,
                            lastSeen: persistedPlayer.lastSeen)
        })

        if let data = try? JSONEncoder().encode(state) {
            userDefaults.set(data, forKey: storageKey)
        }
    }

    private func loadState() -> PersistedState {
        guard let data = userDefaults.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else {
            return PersistedState(selectedPlayerKey: nil, players: [])
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
        definition.type + "::" + definition.id
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
    var selectedPlayerKey: String?
    var players: [PersistedPlayer]
}
