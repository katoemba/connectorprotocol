import XCTest
import SwiftUI
import ConnectorProtocol

/// Browser whose players can never be decoded. Restored players therefore end up as "unrevived", which
/// PlayerManager keeps in persistence, so the persisted state can be asserted without a full PlayerProtocol fake.
private final class StubBrowser: PlayerBrowserProtocol {
    let controllerType = "stub"
    let playerEventStream = AsyncStream<PlayerBrowserEvent> { _ in }
    var predefinedIDs: [String] = []
    var decodedIDs: [String] = []

    func startListening(predefinedPlayers: [PlayerDefinition]) async {
        predefinedIDs = predefinedPlayers.map(\.id)
    }

    func stopListening() async {}

    func decodePlayer(_ playerDefinition: PlayerDefinition) async throws -> any PlayerProtocol {
        decodedIDs.append(playerDefinition.id)
        throw PlayerManagerError.unableToDecodePlayer(playerDefinition)
    }

    func manualAddPlayerView() -> EmptyView { EmptyView() }
}

/// Minimal player. Only identity and definition matter to PlayerManager's bookkeeping.
private final class FakePlayer: PlayerProtocol {
    let controllerType = "stub"
    let discoverMode = DiscoverMode.automatic
    let uniqueID: String
    let name: String
    let model = "", mediaServerModel = "", description = ""
    let hidden = false
    let supportedFunctions: [Functions] = []
    var version = "0.0.0"
    let connectionWarning: String? = nil
    let mediaAvailable = false
    let mediaServers: [BrowseProtocol] = []
    var status: StatusProtocol { fatalError("unused") }
    var control: ControlProtocol { fatalError("unused") }
    var browse: BrowseProtocol { fatalError("unused") }
    let playerStreamURL: URL? = nil
    let diagnosticsInfo: [DiagnosticsItem] = []
    let isManual: Bool
    let payload: Data

    init(id: String, isManual: Bool, payload: String) {
        uniqueID = id
        name = id
        self.isManual = isManual
        self.payload = Data(payload.utf8)
    }

    func updateVersion(_ version: String) { self.version = version }
    func activate() {}
    func deactivate() {}
    func browse(source: SourceType) -> BrowseProtocol? { nil }
    func selectMediaServer(_ mediaServer: BrowseProtocol, source: SourceType) {}
    func favourites() async throws -> [FoundItem] { [] }
    func ping() async -> Bool { true }
    func playerDefinition() throws -> PlayerDefinition {
        PlayerDefinition(id: uniqueID, name: name, type: controllerType, typeSpecificData: payload, isManual: isManual)
    }
    func settingsView(deleteAction: ((any PlayerProtocol) -> ())?,
                      hideAction: ((any PlayerProtocol) -> ())?) -> EmptyView { EmptyView() }
}

/// Browser whose events are driven by the test.
private final class EventBrowser: PlayerBrowserProtocol {
    let controllerType = "stub"
    let playerEventStream: AsyncStream<PlayerBrowserEvent>
    let continuation: AsyncStream<PlayerBrowserEvent>.Continuation

    init() {
        (playerEventStream, continuation) = AsyncStream.makeStream(of: PlayerBrowserEvent.self)
    }

    func startListening(predefinedPlayers: [PlayerDefinition]) async {}
    func stopListening() async {}
    func decodePlayer(_ playerDefinition: PlayerDefinition) async throws -> any PlayerProtocol {
        FakePlayer(id: playerDefinition.id, isManual: playerDefinition.isManual, payload: "")
    }
    func manualAddPlayerView() -> EmptyView { EmptyView() }
}

@MainActor
final class PlayerManagerPersistenceTests: XCTestCase {
    private let storageKey = "test.players"
    private var suiteName = ""
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "PlayerManagerPersistenceTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func store(_ entries: [(id: String, manual: Bool, daysAgo: Double)]) throws {
        let players: [[String: Any]] = try entries.map { entry in
            let definition = PlayerDefinition(id: entry.id, name: entry.id, type: "stub", typeSpecificData: Data(), isManual: entry.manual)
            let definitionJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(definition))
            let lastSeen = Date().addingTimeInterval(-entry.daysAgo * 24 * 60 * 60).timeIntervalSinceReferenceDate
            return ["definition": definitionJSON, "lastSeen": lastSeen]
        }
        userDefaults.set(try JSONSerialization.data(withJSONObject: ["players": players]), forKey: storageKey)
    }

    private func persistedIDs() throws -> Set<String> {
        let data = try XCTUnwrap(userDefaults.data(forKey: storageKey))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let players = try XCTUnwrap(json["players"] as? [[String: Any]])
        return Set(players.compactMap { ($0["definition"] as? [String: Any])?["id"] as? String })
    }

    private func activateAndDeactivate(restoreCachedPlayers: Bool = true, browser: StubBrowser = StubBrowser()) async {
        let manager = PlayerManager(browsers: [AnyPlayerBrowser(browser)],
                                    userDefaults: userDefaults,
                                    userDefaultsKey: storageKey,
                                    restoreCachedPlayers: restoreCachedPlayers)
        await manager.activate(selectedPlayerID: nil)
        await manager.deactivate()
    }

    func testStalePurgeKeepsManualPlayers() async throws {
        try store([("manual", true, 30), ("detected", false, 30), ("recent", false, 1)])

        await activateAndDeactivate()

        XCTAssertEqual(try persistedIDs(), ["manual", "recent"])
    }

    func testUnreadableStateIsBackedUpNotOverwritten() async throws {
        let garbage = Data("not json".utf8)
        userDefaults.set(garbage, forKey: storageKey)

        await activateAndDeactivate()

        XCTAssertEqual(userDefaults.data(forKey: storageKey + ".unreadable"), garbage)
    }

    func testOneUnreadablePlayerDoesNotDropTheOthers() async throws {
        try store([("manual", true, 1)])
        let data = try XCTUnwrap(userDefaults.data(forKey: storageKey))
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        var players = try XCTUnwrap(json["players"] as? [Any])
        players.insert(["definition": "broken"], at: 0)
        json["players"] = players
        userDefaults.set(try JSONSerialization.data(withJSONObject: json), forKey: storageKey)

        await activateAndDeactivate()

        XCTAssertEqual(try persistedIDs(), ["manual"])
    }

    func testStateWithoutIsManualStillDecodes() throws {
        let json = #"{"id":"a","name":"A","type":"stub","typeSpecificData":""}"#
        let definition = try JSONDecoder().decode(PlayerDefinition.self, from: Data(json.utf8))
        XCTAssertFalse(definition.isManual)
    }

    func testCachedPlayersNotRestoredWhenDisabledButKeptInStorage() async throws {
        try store([("manual", true, 1), ("detected", false, 1)])
        let browser = StubBrowser()

        await activateAndDeactivate(restoreCachedPlayers: false, browser: browser)

        XCTAssertEqual(browser.decodedIDs, ["manual"])
        XCTAssertEqual(browser.predefinedIDs, ["manual"])
        XCTAssertEqual(try persistedIDs(), ["manual", "detected"])

        // Re-enabling the setting brings the cached player back.
        let enabledBrowser = StubBrowser()
        await activateAndDeactivate(restoreCachedPlayers: true, browser: enabledBrowser)
        XCTAssertEqual(Set(enabledBrowser.decodedIDs), ["manual", "detected"])
    }

    func testDiscoveryDoesNotOverwriteManualDefinition() async throws {
        let browser = EventBrowser()
        let manager = PlayerManager(browsers: [AnyPlayerBrowser(browser)],
                                    userDefaults: userDefaults,
                                    userDefaultsKey: storageKey)
        await manager.activate(selectedPlayerID: nil)
        manager.addManualPlayer(FakePlayer(id: "host:6600", isManual: true, payload: "with-password"))

        // The same host:port is now also found on the network, without the user's password.
        browser.continuation.yield(.added(FakePlayer(id: "host:6600", isManual: false, payload: "discovered")))
        for _ in 0..<100 where manager.players.first?.isDetected != true {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTAssertEqual(manager.players.first?.isDetected, true)
        await manager.deactivate()

        let data = try XCTUnwrap(userDefaults.data(forKey: storageKey))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let definition = try XCTUnwrap(((json["players"] as? [[String: Any]])?.first)?["definition"] as? [String: Any])
        XCTAssertEqual(definition["isManual"] as? Bool, true)
        let payload = try XCTUnwrap(definition["typeSpecificData"] as? String)
        XCTAssertEqual(Data(base64Encoded: payload), Data("with-password".utf8))
    }

    func testRediscoverKeepsPlayersAndDeliversNewEvents() async throws {
        let browser = EventBrowser()
        let manager = PlayerManager(browsers: [AnyPlayerBrowser(browser)],
                                    userDefaults: userDefaults,
                                    userDefaultsKey: storageKey)
        await manager.activate(selectedPlayerID: nil)
        browser.continuation.yield(.added(FakePlayer(id: "a:1", isManual: false, payload: "")))
        for _ in 0..<100 where manager.players.isEmpty {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTAssertEqual(manager.players.map(\.id), ["a:1"])

        // "Rediscover players"
        await manager.deactivate()
        await manager.activate(selectedPlayerID: nil)
        XCTAssertEqual(manager.players.map(\.id), ["a:1"], "persisted players are restored")

        // Events from the browser must still arrive after reactivation.
        browser.continuation.yield(.added(FakePlayer(id: "b:2", isManual: false, payload: "")))
        for _ in 0..<100 where manager.players.count < 2 {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTAssertEqual(Set(manager.players.map(\.id)), ["a:1", "b:2"])
        await manager.deactivate()
    }

    func testRediscoverRebuildsTheList() async throws {
        let browser = EventBrowser()
        let manager = PlayerManager(browsers: [AnyPlayerBrowser(browser)],
                                    userDefaults: userDefaults,
                                    userDefaultsKey: storageKey)
        await manager.activate(selectedPlayerID: nil)
        browser.continuation.yield(.added(FakePlayer(id: "a:1", isManual: false, payload: "")))
        for _ in 0..<100 where manager.players.isEmpty {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        let before = try XCTUnwrap(manager.players.first?.player)

        await manager.rediscover(selectedPlayerID: nil)

        // Restored from persistence as a new object, so the list was really rebuilt.
        XCTAssertEqual(manager.players.map(\.id), ["a:1"])
        XCTAssertFalse(manager.players.first?.player === before)
        await manager.deactivate()
    }
}
