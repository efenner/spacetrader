// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Phase-1 persistence. The full Palm game used
// `PrefSetAppPreferences` for options and `DmCreateDatabase` for the
// save slot; the Swift port picks a simpler split:
//   - `SaveStore` writes the full `SaveGame` struct as JSON to a
//     user-chosen file (typically `Documents/savegame.json` on iOS).
//   - `GameOptions` lives in `UserDefaults` so preferences outlive a
//     "New Game" (see PLAN.md, Step 12).
//
// There's no compatibility with the original `.pdb` save format —
// that would require reverse-engineering Palm's database layout, and
// the plan documents the break.

import Foundation

/// JSON save/load for `SaveGame`. Inject a URL so tests can point at
/// a throwaway temp file; production callers use `.default` (or their
/// own folder on sandboxed platforms).
public struct SaveStore {

    public let saveFileURL: URL

    public init(saveFileURL: URL) {
        self.saveFileURL = saveFileURL
    }

    /// Default store anchored at `Documents/savegame.json`. On Linux
    /// the `.documentDirectory` search path resolves to
    /// `~/Documents`, which is fine for the test runner and for a
    /// future macOS CLI driver.
    public static var `default`: SaveStore {
        let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        return SaveStore(saveFileURL: docs.appendingPathComponent("savegame.json"))
    }

    /// Returns nil when no save file exists, which the UI should
    /// treat as "first run, start a new game". Any other read/decode
    /// failure is rethrown so the caller can surface a corruption
    /// dialog rather than silently dropping the save.
    public func load() throws -> SaveGame? {
        guard FileManager.default.fileExists(atPath: saveFileURL.path) else {
            return nil
        }
        let data = try Data(contentsOf: saveFileURL)
        return try JSONDecoder().decode(SaveGame.self, from: data)
    }

    public func save(_ game: SaveGame) throws {
        let parent = saveFileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: parent, withIntermediateDirectories: true
        )
        let data = try JSONEncoder().encode(game)
        try data.write(to: saveFileURL, options: .atomic)
    }

    public func delete() throws {
        if FileManager.default.fileExists(atPath: saveFileURL.path) {
            try FileManager.default.removeItem(at: saveFileURL)
        }
    }
}
