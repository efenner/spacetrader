// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class PersistenceTests: XCTestCase {

    private var tempDir: URL!

    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpaceTraderTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    private func makeStore() -> SaveStore {
        SaveStore(saveFileURL: tempDir.appendingPathComponent("savegame.json"))
    }

    private func freshDefaults() -> UserDefaults {
        // Per-test suite so tests can't stomp on each other. Names can't
        // be reused within a process, so we UUID-qualify them.
        let suite = "com.spacetrader.tests.\(UUID().uuidString)"
        let d = UserDefaults(suiteName: suite)!
        d.removePersistentDomain(forName: suite)
        return d
    }

    // MARK: SaveStore — basic round-trip

    func testLoadReturnsNilWhenNoSaveExists() throws {
        let store = makeStore()
        XCTAssertNil(try store.load())
    }

    func testSaveThenLoadRoundTrip() throws {
        let store = makeStore()
        var game = SaveGame()
        game.credits = 12_345
        game.debt = 500
        game.days = 17
        game.policeRecordScore = PoliceRecordScore.trusted
        game.ship.weapon[0] = WeaponIndex.beamLaser

        try store.save(game)
        let loaded = try XCTUnwrap(try store.load())

        // SaveGame isn't Equatable-conformed yet, so verify via
        // byte-identical re-encode. Sort keys so we compare content,
        // not dictionary iteration order.
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        XCTAssertEqual(try encoder.encode(loaded), try encoder.encode(game))
    }

    func testSaveIsAtomicOverwrite() throws {
        let store = makeStore()
        var game = SaveGame()
        game.credits = 100
        try store.save(game)
        game.credits = 200
        try store.save(game)
        XCTAssertEqual(try store.load()?.credits, 200)
    }

    func testDeleteRemovesTheFile() throws {
        let store = makeStore()
        try store.save(SaveGame())
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.saveFileURL.path))
        try store.delete()
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.saveFileURL.path))
        XCTAssertNil(try store.load())
    }

    func testSaveCreatesIntermediateDirectories() throws {
        // Nest the save file two levels deep; save() must create them.
        let nested = tempDir
            .appendingPathComponent("a", isDirectory: true)
            .appendingPathComponent("b", isDirectory: true)
            .appendingPathComponent("game.json")
        let store = SaveStore(saveFileURL: nested)
        try store.save(SaveGame())
        XCTAssertNotNil(try store.load())
    }

    // MARK: GameOptions — round trip

    func testGameOptionsFromSaveExtractsFlags() {
        var game = SaveGame()
        game.autoFuel = true
        game.clicks = true
        game.alwaysIgnoreTraders = true
        let opts = GameOptions(save: game)
        XCTAssertTrue(opts.autoFuel)
        XCTAssertTrue(opts.clicks)
        XCTAssertTrue(opts.alwaysIgnoreTraders)
        XCTAssertFalse(opts.autoRepair)
    }

    func testGameOptionsApplyWritesBackToSave() {
        var game = SaveGame()
        let opts = GameOptions(autoFuel: true, continuous: true, reserveMoney: true)
        opts.apply(to: &game)
        XCTAssertTrue(game.autoFuel)
        XCTAssertTrue(game.continuous)
        XCTAssertTrue(game.reserveMoney)
    }

    // MARK: OptionStore — UserDefaults round-trip

    func testOptionStoreRoundTripThroughUserDefaults() throws {
        let defaults = freshDefaults()
        let opts = GameOptions(autoFuel: true, clicks: true, continuous: true)
        try OptionStore.save(opts, defaults: defaults)
        let loaded = OptionStore.load(defaults: defaults)
        XCTAssertEqual(loaded, opts)
    }

    func testOptionStoreLoadReturnsNilWhenEmpty() {
        let defaults = freshDefaults()
        XCTAssertNil(OptionStore.load(defaults: defaults))
    }

    func testOptionStoreClearRemovesKey() throws {
        let defaults = freshDefaults()
        try OptionStore.save(GameOptions(clicks: true), defaults: defaults)
        XCTAssertNotNil(OptionStore.load(defaults: defaults))
        OptionStore.clear(defaults: defaults)
        XCTAssertNil(OptionStore.load(defaults: defaults))
    }

    // MARK: GameState.resetPreservingOptions

    func testResetPreservingOptionsKeepsUserPrefs() {
        let gs = GameState()
        gs.save.autoFuel = true
        gs.save.alwaysIgnorePirates = true
        gs.credits = 99_999
        gs.debt = 12_345

        gs.resetPreservingOptions()

        // Options survived.
        XCTAssertTrue(gs.save.autoFuel)
        XCTAssertTrue(gs.save.alwaysIgnorePirates)
        // Game-state fields were reset.
        XCTAssertEqual(gs.credits, 1_000)    // SaveGame default starting cash
        XCTAssertEqual(gs.debt, 0)
    }
}
