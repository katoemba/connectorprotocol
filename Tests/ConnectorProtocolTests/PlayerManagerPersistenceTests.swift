import XCTest
import SwiftUI
@testable import ConnectorProtocol

/// Browser whose players can never be decoded. Restored players therefore end up as "unrevived", which
/// PlayerManager keeps in persistence, so the persisted state can be asserted without a full PlayerProtocol fake.
private final class StubBrowser: PlayerBrowserProtocol, @unchecked Sendable {
    let controllerType = "stub"
    let playerEventStream = AsyncStream<PlayerBrowserEvent> { _ in }
    private let lock = NSLock()
    private var _predefinedIDs: [String] = []
    private var _decodedIDs: [String] = []

    // Players are decoded concurrently, so the recording has to be safe for that.
    var predefinedIDs: [String] { lock.withLock { _predefinedIDs } }
    var decodedIDs: [String] { lock.withLock { _decodedIDs } }

    func startListening(predefinedPlayers: [PlayerDefinition]) async {
        lock.withLock { _predefinedIDs = predefinedPlayers.map(\.id) }
    }

    func stopListening() async {}

    func decodePlayer(_ playerDefinition: PlayerDefinition) async throws -> any PlayerProtocol {
        lock.withLock { _decodedIDs.append(playerDefinition.id) }
        throw PlayerManagerError.unableToDecodePlayer(playerDefinition)
    }

    func manualAddPlayerView() -> EmptyView { EmptyView() }
}

/// Minimal player. Only identity and definition matter to PlayerManager's bookkeeping.
private final class FakePlayer: PlayerProtocol, @unchecked Sendable {
    let controllerType = "stub"
    let discoverMode = DiscoverMode.automatic
    let uniqueID: String
    let name: String
    let model = "", mediaServerModel = "", description = ""
    let hidden = false
    let supportedFunctions: [Functions] = []
    let connectionWarning: String? = nil
    let mediaAvailable = false
    let mediaServers: [BrowseProtocol] = []
    var status: StatusProtocol { fatalError("unused") }
    var control: ControlProtocol { fatalError("unused") }
    var browse: BrowseProtocol { fatalError("unused") }
    let playerStreamURL: URL? = nil
    let diagnosticsInfo: [DiagnosticsItem] = []
    let isManual: Bool
    let isReachable: Bool

    // Pinged off the main actor while tests change these, so access goes through a lock.
    private let lock = NSLock()
    private var _version = "0.0.0"
    private var _payload: Data
    private var _pingDelay: TimeInterval

    var version: String { lock.withLock { _version } }
    var payload: Data {
        get { lock.withLock { _payload } }
        set { lock.withLock { _payload = newValue } }
    }
    var pingDelay: TimeInterval {
        get { lock.withLock { _pingDelay } }
        set { lock.withLock { _pingDelay = newValue } }
    }

    init(id: String, isManual: Bool, payload: String, pingDelay: TimeInterval = 0, isReachable: Bool = true) {
        uniqueID = id
        name = id
        self.isManual = isManual
        _payload = Data(payload.utf8)
        _pingDelay = pingDelay
        self.isReachable = isReachable
    }

    func updateVersion(_ version: String) { lock.withLock { _version = version } }
    func activate() {}
    func deactivate() {}
    func browse(source: SourceType) -> BrowseProtocol? { nil }
    func selectMediaServer(_ mediaServer: BrowseProtocol, source: SourceType) {}
    func favourites() async throws -> [FoundItem] { [] }
    func ping() async -> Bool {
        if pingDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(pingDelay * 1_000_000_000))
        }
        return isReachable
    }
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

/// Records what PlayerManager asks of a browser, and lets a test decide how slow decoding and pinging are.
private final class ConfigurableBrowser: PlayerBrowserProtocol, @unchecked Sendable {
    let controllerType = "stub"
    let playerEventStream: AsyncStream<PlayerBrowserEvent>
    let continuation: AsyncStream<PlayerBrowserEvent>.Continuation

    private let lock = NSLock()
    private var _decodeDelays: [String: TimeInterval] = [:]
    private var _failingIDs: Set<String> = []
    private var _pingDelay: TimeInterval = 0
    private var _isReachable = true
    private var _startDates: [Date] = []
    private var _stopCount = 0
    private var _isListening = false
    private var _predefinedIDs: [String] = []
    private var _playerIDsAtStart: [String] = []
    private var _decodedIDs: [String] = []
    private var _removedIDs: [String] = []
    weak var manager: PlayerManager?

    init() {
        (playerEventStream, continuation) = AsyncStream.makeStream(of: PlayerBrowserEvent.self)
    }

    private func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

    var decodeDelays: [String: TimeInterval] {
        get { locked { _decodeDelays } }
        set { locked { _decodeDelays = newValue } }
    }
    var failingIDs: Set<String> {
        get { locked { _failingIDs } }
        set { locked { _failingIDs = newValue } }
    }
    var pingDelay: TimeInterval {
        get { locked { _pingDelay } }
        set { locked { _pingDelay = newValue } }
    }
    var isReachable: Bool {
        get { locked { _isReachable } }
        set { locked { _isReachable = newValue } }
    }
    var decodedIDs: [String] { locked { _decodedIDs } }
    var removedIDs: [String] { locked { _removedIDs } }
    var startDates: [Date] { locked { _startDates } }
    var stopCount: Int { locked { _stopCount } }
    var isListening: Bool { locked { _isListening } }
    var predefinedIDs: [String] { locked { _predefinedIDs } }
    /// The ids in the manager's list at the moment the browser was told to start listening.
    var playerIDsAtStart: [String] { locked { _playerIDsAtStart } }

    func startListening(predefinedPlayers: [PlayerDefinition]) async {
        let idsInManager = await MainActor.run { manager?.players.map(\.id) ?? [] }
        locked {
            _startDates.append(Date())
            _isListening = true
            _predefinedIDs = predefinedPlayers.map(\.id)
            _playerIDsAtStart = idsInManager
        }
    }

    func stopListening() async {
        locked {
            _stopCount += 1
            _isListening = false
        }
    }

    func decodePlayer(_ playerDefinition: PlayerDefinition) async throws -> any PlayerProtocol {
        let (delay, fails, pingDelay, isReachable) = locked {
            _decodedIDs.append(playerDefinition.id)
            return (_decodeDelays[playerDefinition.id], _failingIDs.contains(playerDefinition.id), _pingDelay, _isReachable)
        }
        if let delay {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        if fails {
            throw PlayerManagerError.unableToDecodePlayer(playerDefinition)
        }
        // Like MPD's attributes, the type specific data records whether a player is manual, whatever the
        // definition around it says.
        let payload = String(decoding: playerDefinition.typeSpecificData, as: UTF8.self)
        return FakePlayer(id: playerDefinition.id,
                          isManual: playerDefinition.isManual || payload == "manual",
                          payload: payload,
                          pingDelay: pingDelay,
                          isReachable: isReachable)
    }

    func playerRemoved(_ playerDefinition: PlayerDefinition) {
        locked { _removedIDs.append(playerDefinition.id) }
    }

    /// Like MPD, the type specific data records whether a player is manual, whatever the definition says.
    func isManualPlayer(_ playerDefinition: PlayerDefinition) -> Bool {
        playerDefinition.isManual || String(decoding: playerDefinition.typeSpecificData, as: UTF8.self) == "manual"
    }

    func manualAddPlayerView() -> EmptyView { EmptyView() }
}

@MainActor
final class PlayerManagerPersistenceTests: XCTestCase {
    private let storageKey = "test.players"
    private var suiteName = ""
    private var userDefaults: UserDefaults!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "PlayerManagerPersistenceTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() async throws {
        userDefaults.removePersistentDomain(forName: suiteName)
        try await super.tearDown()
    }

    private func store(_ entries: [(id: String, manual: Bool, daysAgo: Double)]) throws {
        let players: [[String: Any]] = try entries.map { entry in
            let definition = PlayerDefinition(id: entry.id, name: entry.id, type: "stub", typeSpecificData: Data(), isManual: entry.manual)
            let definitionJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(definition))
            let lastSeen = Date().addingTimeInterval(-entry.daysAgo * 24 * 60 * 60).timeIntervalSinceReferenceDate
            return ["definition": definitionJSON, "lastSeen": lastSeen]
        }
        userDefaults.set(try JSONSerialization.data(withJSONObject: ["formatVersion": 2, "players": players]), forKey: storageKey)
    }

    /// State as the released build wrote it: no format version, and definitions without `isManual`. Whether a
    /// player is manual is only recorded in its payload ("manual" or "auto").
    private func storeOldFormat(_ entries: [(id: String, payload: String, daysAgo: Double)]) throws {
        let players: [[String: Any]] = entries.map { entry in
            let definition: [String: Any] = ["id": entry.id, "name": entry.id, "type": "stub",
                                             "typeSpecificData": Data(entry.payload.utf8).base64EncodedString()]
            let lastSeen = Date().addingTimeInterval(-entry.daysAgo * 24 * 60 * 60).timeIntervalSinceReferenceDate
            return ["definition": definition, "lastSeen": lastSeen]
        }
        userDefaults.set(try JSONSerialization.data(withJSONObject: ["players": players]), forKey: storageKey)
    }

    private func persistedJSON() throws -> [String: Any] {
        let data = try XCTUnwrap(userDefaults.data(forKey: storageKey))
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func persistedDefinition(_ id: String) throws -> [String: Any] {
        let players = try XCTUnwrap(persistedJSON()["players"] as? [[String: Any]])
        return try XCTUnwrap(players.compactMap { $0["definition"] as? [String: Any] }.first { $0["id"] as? String == id })
    }

    private func makeManager(browser: ConfigurableBrowser, restoreCachedPlayers: Bool = true) -> PlayerManager {
        let manager = PlayerManager(browsers: [AnyPlayerBrowser(browser)],
                                    userDefaults: userDefaults,
                                    userDefaultsKey: storageKey,
                                    reachabilityRefreshInterval: 1.0,
                                    restoreCachedPlayers: restoreCachedPlayers)
        browser.manager = manager
        return manager
    }

    /// Poll until `condition` holds, for at most `timeout` seconds.
    private func waitUntil(_ timeout: TimeInterval = 3, _ condition: () -> Bool) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
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

    // MARK: - State written by the released build

    func testOldFormatStateIsUpgradedBeforeStalePlayersArePurged() async throws {
        try storeOldFormat([("manual", "manual", 30), ("detected", "auto", 30), ("recent", "auto", 1)])
        let browser = ConfigurableBrowser()
        let manager = makeManager(browser: browser)

        await manager.activate(selectedPlayerID: nil)
        await manager.deactivate()

        // The manual player was idle for 30 days, but it is manual, which only its payload says.
        XCTAssertEqual(try persistedIDs(), ["manual", "recent"])
        XCTAssertEqual(try persistedDefinition("manual")["isManual"] as? Bool, true)
        XCTAssertEqual(try persistedDefinition("recent")["isManual"] as? Bool, false)
        XCTAssertEqual(try persistedJSON()["formatVersion"] as? Int, 2)
    }

    func testOldFormatManualPlayerIsStillRestoredWhenCachedPlayersAreOff() async throws {
        try storeOldFormat([("manual", "manual", 30), ("cached", "auto", 1)])
        let browser = ConfigurableBrowser()
        let manager = makeManager(browser: browser, restoreCachedPlayers: false)

        await manager.activate(selectedPlayerID: nil)

        XCTAssertEqual(manager.players.map(\.id), ["manual"])
        XCTAssertEqual(browser.predefinedIDs, ["manual"])
        await manager.deactivate()
        XCTAssertEqual(try persistedIDs(), ["manual", "cached"])
    }

    // MARK: - Lifecycle

    func testScheduledDeactivationIsCancelledWhenTheAppBecomesActiveAgain() async throws {
        let browser = ConfigurableBrowser()
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)

        // The app resigns active for a moment (Control Center, a system alert) and comes back.
        manager.scheduleDeactivation(after: 0.2)
        try await Task.sleep(nanoseconds: 50_000_000)
        await manager.activate(selectedPlayerID: nil)
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertTrue(manager.isListening)
        XCTAssertTrue(browser.isListening)
        XCTAssertEqual(browser.stopCount, 0)
        await manager.deactivate()
    }

    func testScheduledDeactivationRunsAfterTheDelay() async throws {
        let browser = ConfigurableBrowser()
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)

        manager.scheduleDeactivation(after: 0.1)
        try await waitUntil { !manager.isListening }

        XCTAssertFalse(manager.isListening)
        XCTAssertFalse(browser.isListening)
        XCTAssertEqual(browser.stopCount, 1)
    }

    func testDeactivateDuringASlowActivateLeavesTheManagerDeactivated() async throws {
        try store([("selected", true, 1), ("other", true, 1)])
        let browser = ConfigurableBrowser()
        browser.decodeDelays = ["selected": 0.3]
        let manager = makeManager(browser: browser)

        let activation = Task { await manager.activate(selectedPlayerID: "selected") }
        try await Task.sleep(nanoseconds: 100_000_000)
        await manager.deactivate()
        await activation.value

        XCTAssertFalse(manager.isListening)
        XCTAssertFalse(browser.isListening, "the browser must not be left running by an activate that was overtaken")
        XCTAssertEqual(browser.startDates.count, 1)
        XCTAssertEqual(browser.stopCount, 1)
    }

    // MARK: - Restoring cached players

    func testDiscoveryStartsWithoutWaitingForCachedPlayers() async throws {
        try store((1...4).map { ("p\($0)", false, 1) })
        let browser = ConfigurableBrowser()
        browser.decodeDelays = Dictionary(uniqueKeysWithValues: (1...4).map { ("p\($0)", 0.5) })
        browser.pingDelay = 0.5
        browser.isReachable = false
        let manager = makeManager(browser: browser)

        let start = Date()
        await manager.activate(selectedPlayerID: nil)
        let activationTime = Date().timeIntervalSince(start)

        let startedAfter = try XCTUnwrap(browser.startDates.first).timeIntervalSince(start)
        XCTAssertLessThan(startedAfter, 0.3, "discovery must not wait for the cached players")
        // Decoded together, not one after the other (which would take 4 x 0.5 s).
        XCTAssertLessThan(activationTime, 1.5)
        XCTAssertEqual(manager.players.map(\.id), ["p1", "p2", "p3", "p4"])
        await manager.deactivate()
    }

    func testSelectedPlayerIsRestoredBeforeDiscoveryStarts() async throws {
        try store([("a", false, 1), ("selected", false, 1), ("b", false, 1)])
        let browser = ConfigurableBrowser()
        browser.decodeDelays = ["selected": 0.1, "a": 0.2, "b": 0.2]
        let manager = makeManager(browser: browser)

        await manager.activate(selectedPlayerID: "selected")

        XCTAssertEqual(browser.playerIDsAtStart, ["selected"])
        XCTAssertEqual(manager.players.map(\.id), ["a", "b", "selected"])
        await manager.deactivate()
    }

    func testRestoredPlayersGetTheirReachabilityWithoutWaitingForTheNextCycle() async throws {
        try store([("a", false, 1), ("b", false, 1), ("c", false, 1)])
        let browser = ConfigurableBrowser()
        browser.pingDelay = 0.2
        let manager = makeManager(browser: browser)

        await manager.activate(selectedPlayerID: nil)
        // Well before the next reachability cycle (1 second in these tests).
        try await waitUntil(0.7) { manager.players.allSatisfy(\.isReachable) }

        XCTAssertEqual(manager.players.count, 3)
        XCTAssertTrue(manager.players.allSatisfy(\.isReachable))
        await manager.deactivate()
    }

    func testPersistedStateKeepsPlayersThatAreStillBeingRestored() async throws {
        try store([("a", true, 1), ("b", true, 1), ("c", true, 1)])
        let browser = ConfigurableBrowser()
        browser.decodeDelays = ["c": 0.6]
        let manager = makeManager(browser: browser)

        let activation = Task { await manager.activate(selectedPlayerID: nil) }
        try await Task.sleep(nanoseconds: 150_000_000)

        // A browser announces a player while c is still being restored. That persists the state, which must
        // not drop c: if the app were killed right now, c would be gone for good.
        browser.continuation.yield(.added(FakePlayer(id: "d", isManual: false, payload: "")))
        try await waitUntil { manager.players.contains { $0.id == "d" } }

        XCTAssertFalse(manager.players.contains { $0.id == "c" }, "c should still be restoring")
        XCTAssertEqual(try persistedIDs(), ["a", "b", "c", "d"])
        await activation.value
        await manager.deactivate()
    }

    func testPlayerRemovedWhileBeingRestoredStaysRemoved() async throws {
        try store([("a", true, 1), ("b", true, 1)])
        let browser = ConfigurableBrowser()
        browser.decodeDelays = ["b": 0.4]
        let manager = makeManager(browser: browser)

        let activation = Task { await manager.activate(selectedPlayerID: nil) }
        try await Task.sleep(nanoseconds: 100_000_000)
        manager.removePlayer(id: "b")
        await activation.value

        XCTAssertEqual(manager.players.map(\.id), ["a"])
        XCTAssertEqual(try persistedIDs(), ["a"])
        await manager.deactivate()
    }

    func testUnrevivedPlayerIsRevivedLater() async throws {
        try store([("x", false, 1)])
        let browser = ConfigurableBrowser()
        browser.failingIDs = ["x"]
        let manager = makeManager(browser: browser)

        await manager.activate(selectedPlayerID: nil)
        XCTAssertTrue(manager.players.isEmpty)
        XCTAssertEqual(try persistedIDs(), ["x"], "a player that can't be revived yet stays in storage")

        browser.failingIDs = []
        try await waitUntil(4) { manager.players.contains { $0.id == "x" } }

        XCTAssertEqual(manager.players.map(\.id), ["x"])
        XCTAssertEqual(try persistedIDs(), ["x"])
        await manager.deactivate()
    }

    func testAnnouncedPlayersAreNotHeldUpByTheirPings() async throws {
        let browser = EventBrowser()
        let manager = PlayerManager(browsers: [AnyPlayerBrowser(browser)],
                                    userDefaults: userDefaults,
                                    userDefaultsKey: storageKey)
        await manager.activate(selectedPlayerID: nil)

        // Three players that don't answer: pinging each takes 0.5 s.
        let start = Date()
        for id in ["a:1", "b:2", "c:3"] {
            browser.continuation.yield(.added(FakePlayer(id: id, isManual: false, payload: "", pingDelay: 0.5, isReachable: false)))
        }
        try await waitUntil { manager.players.count == 3 }

        // Handled one after the other, waiting for each ping, this would take 1.5 s.
        XCTAssertEqual(manager.players.count, 3)
        XCTAssertLessThan(Date().timeIntervalSince(start), 0.4)
        await manager.deactivate()
    }

    func testUpgradeOfOldStateNeverDecodesPlayers() async throws {
        // Decoding a player can mean talking to the device (OpenHome), which would hold up the first launch.
        try storeOldFormat([("manual", "manual", 30), ("gone", "auto", 30), ("recent", "auto", 1)])
        let browser = ConfigurableBrowser()
        let manager = makeManager(browser: browser)

        await manager.activate(selectedPlayerID: nil)
        await manager.deactivate()

        XCTAssertEqual(try persistedIDs(), ["manual", "recent"])
        XCTAssertFalse(browser.decodedIDs.contains("gone"), "a purged player is not decoded at all")
        XCTAssertEqual(Set(browser.decodedIDs), ["manual", "recent"], "each remaining player is decoded once")
    }

    // MARK: - Manual players and staleness

    func testManualDefinitionSurvivesWhenDiscoveryAnnouncesThePlayerDuringTheRestore() async throws {
        try store([("nas:6600", true, 1)])
        let browser = ConfigurableBrowser()
        browser.decodeDelays = ["nas:6600": 0.4]
        let manager = makeManager(browser: browser)

        let activation = Task { await manager.activate(selectedPlayerID: nil) }
        try await Task.sleep(nanoseconds: 100_000_000)
        // Bonjour finds the same host and port, without knowing it was added manually.
        browser.continuation.yield(.added(FakePlayer(id: "nas:6600", isManual: false, payload: "discovered")))
        await activation.value

        XCTAssertEqual(manager.players.first?.definition.isManual, true)
        await manager.deactivate()
        XCTAssertEqual(try persistedDefinition("nas:6600")["isManual"] as? Bool, true)
    }

    func testRemovingAPlayerLetsItsBrowserForgetIt() async throws {
        try store([("manual", true, 1), ("unrevived", true, 1)])
        let browser = ConfigurableBrowser()
        browser.failingIDs = ["unrevived"]
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)

        manager.removePlayer(id: "manual")
        manager.removePlayer(id: "unrevived")
        manager.removePlayer(id: "unknown")

        XCTAssertEqual(browser.removedIDs, ["manual", "unrevived"])
        await manager.deactivate()
        XCTAssertEqual(try persistedIDs(), [])
    }

    func testAPlayerThatKeepsAnsweringDoesNotGoStaleWhileTheAppRuns() async throws {
        let browser = ConfigurableBrowser()
        let manager = PlayerManager(browsers: [AnyPlayerBrowser(browser)],
                                    userDefaults: userDefaults,
                                    userDefaultsKey: storageKey,
                                    stalePlayerInterval: 1.5,
                                    reachabilityRefreshInterval: 1.0)
        browser.manager = manager
        await manager.activate(selectedPlayerID: nil)
        browser.continuation.yield(.added(FakePlayer(id: "a:1", isManual: false, payload: "")))
        try await waitUntil { manager.players.contains { $0.id == "a:1" } }

        // Announced once, then only answering pings for longer than the stale interval.
        try await Task.sleep(nanoseconds: 2_600_000_000)
        let lastSeen = try XCTUnwrap(manager.players.first?.lastSeen)
        XCTAssertLessThan(Date().timeIntervalSince(lastSeen), 1.3, "a successful ping counts as seeing the player")

        // Now it disappears from the network: it shows as gone, it is not purged on the spot.
        browser.continuation.yield(.removed("a:1"))
        try await waitUntil { manager.players.first?.isDetected == false }
        XCTAssertEqual(manager.players.map(\.id), ["a:1"])
        await manager.deactivate()
    }

    func testAPlayerThatDisappearsIsNotPurgedOnTheSpot() async throws {
        let browser = ConfigurableBrowser()
        let manager = PlayerManager(browsers: [AnyPlayerBrowser(browser)],
                                    userDefaults: userDefaults,
                                    userDefaultsKey: storageKey,
                                    stalePlayerInterval: 1.5,
                                    reachabilityRefreshInterval: 1.0)
        browser.manager = manager
        await manager.activate(selectedPlayerID: nil)
        // Announced once and never answering a ping since, for longer than the stale interval.
        browser.continuation.yield(.added(FakePlayer(id: "a:1", isManual: false, payload: "", isReachable: false)))
        try await waitUntil { manager.players.contains { $0.id == "a:1" } }
        try await Task.sleep(nanoseconds: 2_000_000_000)

        // It was announced until now, so disappearing starts the stale period instead of ending it.
        browser.continuation.yield(.removed("a:1"))
        try await waitUntil { manager.players.first?.isDetected == false }
        XCTAssertEqual(manager.players.map(\.id), ["a:1"])
        await manager.deactivate()
    }

    // MARK: - Replacing stale objects, reviving

    func testAnUnreachablePlayerIsReplacedByAnAnnouncedOneThatAnswers() async throws {
        try store([("a:1", false, 1)])
        let browser = ConfigurableBrowser()
        browser.isReachable = false   // the restored object has an address that no longer works
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)
        let restored = try XCTUnwrap(manager.players.first?.player)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Discovery finds it again, with connection details that work.
        let found = FakePlayer(id: "a:1", isManual: false, payload: "", isReachable: true)
        browser.continuation.yield(.added(found))
        try await waitUntil { manager.players.first?.player === found }

        XCTAssertTrue(manager.players.first?.player === found)
        XCTAssertFalse(manager.players.first?.player === restored)
        XCTAssertEqual(manager.players.first?.isReachable, true)
        await manager.deactivate()
    }

    func testAReachablePlayerKeepsItsObjectWhenAnnouncedAgain() async throws {
        try store([("a:1", false, 1)])
        let browser = ConfigurableBrowser()
        browser.pingDelay = 0.5   // the restored object's first ping is still under way when it is announced
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)
        let restored = try XCTUnwrap(manager.players.first?.player)
        XCTAssertEqual(manager.players.first?.isReachable, false)

        // Announced before the restored object's first ping came back: that one still answers, so it stays.
        browser.continuation.yield(.added(FakePlayer(id: "a:1", isManual: false, payload: "", isReachable: true)))
        try await waitUntil { manager.players.first?.isReachable == true }
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(manager.players.first?.player === restored)
        await manager.deactivate()
    }

    func testPlayersAreRevivedTogether() async throws {
        try store([("x", false, 1), ("y", false, 1)])
        let browser = ConfigurableBrowser()
        browser.failingIDs = ["x", "y"]
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)

        // Both come back, each taking 1.5 s to decode: one after the other would take at least 3 s.
        browser.decodeDelays = ["x": 1.5, "y": 1.5]
        browser.failingIDs = []
        let start = Date()
        try await waitUntil(5) { manager.players.count == 2 }

        XCTAssertEqual(Set(manager.players.map(\.id)), ["x", "y"])
        XCTAssertLessThan(Date().timeIntervalSince(start), 2.8)
        await manager.deactivate()
    }

    func testAPingOfAReplacedObjectDoesNotCountForItsReplacement() async throws {
        try store([("a:1", false, 1)])
        let browser = ConfigurableBrowser()
        browser.isReachable = false   // the restored object has an address that no longer works
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)
        let restored = try XCTUnwrap(manager.players.first?.player as? FakePlayer)

        // The reachability round after 1 s pings the restored object, which takes until 3 s to answer.
        restored.pingDelay = 2
        try await Task.sleep(nanoseconds: 1_200_000_000)
        restored.pingDelay = 0

        // Meanwhile it is found again, and replaced by the found object, which answers.
        let found = FakePlayer(id: "a:1", isManual: false, payload: "", isReachable: true)
        browser.continuation.yield(.added(found))
        try await waitUntil { manager.players.first?.player === found }
        XCTAssertEqual(manager.players.first?.isReachable, true)

        // The old object's answer comes in at 3 s; the next round is only at 4 s.
        try await Task.sleep(nanoseconds: 2_100_000_000)
        XCTAssertEqual(manager.players.first?.isReachable, true, "the old object's ping says nothing about the new one")
        await manager.deactivate()
    }

    // MARK: - Settings changed on the player

    func testASettingChangedOnThePlayerIsPersisted() async throws {
        try store([("a:1", true, 1)])
        let browser = ConfigurableBrowser()
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)
        let player = try XCTUnwrap(manager.players.first?.player as? FakePlayer)

        // E.g. the user picks another type in the player settings; nothing announces the player again.
        player.payload = Data("changed".utf8)
        try await waitUntil {
            (try? persistedDefinition("a:1")["typeSpecificData"] as? String) == Data("changed".utf8).base64EncodedString()
        }

        XCTAssertEqual(try persistedDefinition("a:1")["typeSpecificData"] as? String, Data("changed".utf8).base64EncodedString())
        XCTAssertEqual(try persistedDefinition("a:1")["isManual"] as? Bool, true)
        XCTAssertEqual(manager.players.first?.definition.typeSpecificData, Data("changed".utf8))
        await manager.deactivate()
    }

    func testADiscoveredObjectStandingInForAManualPlayerDoesNotOverwriteItsDefinition() async throws {
        try store([("a:1", true, 1)])
        let browser = ConfigurableBrowser()
        browser.isReachable = false
        let manager = makeManager(browser: browser)
        await manager.activate(selectedPlayerID: nil)

        // A discovered player with the same id answers where the manual one doesn't, and takes its place.
        let found = FakePlayer(id: "a:1", isManual: false, payload: "discovered", isReachable: true)
        browser.continuation.yield(.added(found))
        try await waitUntil { manager.players.first?.player === found }
        try await Task.sleep(nanoseconds: 1_300_000_000)

        XCTAssertEqual(manager.players.first?.definition.isManual, true)
        XCTAssertEqual(manager.players.first?.definition.typeSpecificData, Data())
        XCTAssertEqual(try persistedDefinition("a:1")["isManual"] as? Bool, true)
        await manager.deactivate()
    }
}
