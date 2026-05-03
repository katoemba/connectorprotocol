import Foundation
import Observation
import SwiftUI
import os.log

public final class AnyPlayerBrowser {
    private let _controllerType: () -> String
    private let _playerEventStream: () -> AsyncStream<PlayerBrowserEvent>
    private let _startListening: ([PlayerDefinition]) async -> Void
    private let _stopListening: () async -> Void
    private let _decodePlayer: (PlayerDefinition) async throws -> any PlayerProtocol

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

    public func activate(selectedPlayerID: String?) async {
        Self.logger.debug("Initializing")
        if isListening {
            return
        }

        isListening = true
        startBrowserEventSubscriptions()
        Self.logger.debug("EventSubscriptions started")

        await restorePlayersFromPersistence(selectedPlayerID: selectedPlayerID)
        Self.logger.debug("Players restored from persistence")
        
        await startBrowsersListening()
        Self.logger.debug("Browser are listening")

        //await ingestCurrentBrowserPlayers()
        startReachabilityRefreshLoop()
        Self.logger.debug("Reachability refresh loop started")
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
        persistState()
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

    private func restorePlayersFromPersistence(selectedPlayerID: String?) async {
        var state = loadState()
        let now = Date()

        state.players.removeAll {
            now.timeIntervalSince($0.lastSeen) > stalePlayerInterval
        }

        players.removeAll()

        Self.logger.debug("Before hitting the selected player \(selectedPlayerID ?? "none")")
        if let selectedPlayerID,
           let selectedPersisted = state.players.first(where: { Self.playerKey(for: $0.definition) == selectedPlayerID }),
           let selectedPlayer = try? await decodePlayer(from: selectedPersisted.definition) {
            Self.logger.debug("Before upserting the selected player")
            upsertPlayer(selectedPlayer,
                         definition: selectedPersisted.definition,
                         key: selectedPlayerID,
                         isDetected: false,
                         lastSeen: selectedPersisted.lastSeen)
            Self.logger.debug("Before checking reachability of the selected player")
            await refreshReachability(for: selectedPlayerID)
        }
        Self.logger.debug("After hitting the selected player")

        for persisted in state.players {
            Self.logger.debug("Hitting player \(persisted.definition.name)")
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
            Self.logger.debug("Reachability completed for player \(persisted.definition.name)")
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
        guard let player = players.first(where: { $0.id == key })?.player else {
            return
        }

        let isReachable = await Task.detached { await player.ping() }.value
        guard let index = players.firstIndex(where: { $0.id == key }) else {
            return
        }

        players[index].isReachable = isReachable
    }

    private func removeStalePlayers(referenceDate: Date) {
        players.removeAll {
            !($0.isDetected) && referenceDate.timeIntervalSince($0.lastSeen) > stalePlayerInterval
        }
    }

    private func upsertPlayer(_ player: any PlayerProtocol,
                              definition: PlayerDefinition,
                              key: String,
                              isDetected: Bool,
                              lastSeen: Date) {
        DispatchQueue.main.async {
            if let index = self.players.firstIndex(where: { $0.id == key }) {
                self.players[index].player = player
                self.players[index].definition = definition
                self.players[index].isDetected = isDetected
                self.players[index].lastSeen = max(self.players[index].lastSeen, lastSeen)
            } else {
                var players = self.players
                players.append(ManagedPlayer(id: key,
                                             definition: definition,
                                             player: player,
                                             isReachable: false,
                                             isDetected: isDetected,
                                             lastSeen: lastSeen))
                self.players = players.sorted(by: {
                    $0.player.name < $1.player.name
                })
            }
        }
    }

    private func persistState() {
        let state = PersistedState(players: players.map { persistedPlayer in
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
    var players: [PersistedPlayer]
}
