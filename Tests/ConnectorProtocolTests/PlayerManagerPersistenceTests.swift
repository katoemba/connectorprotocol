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
}
