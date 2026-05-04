import Foundation
import SQLite3

final class BlocklistDatabase {
    static let shared = BlocklistDatabase()

    private var db: OpaquePointer?
    private let dbPath: String

    private init() {
        let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SpamSentryShared.appGroupIdentifier
        )
        dbPath = (containerURL?.path ?? NSTemporaryDirectory()) + "/blocklist.sqlite"
        openDatabase()
        createTables()
    }

    private func openDatabase() {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            NSLog("SpamSentry: Cannot open database at \(dbPath)")
        }
    }

    private func createTables() {
        execute("""
            CREATE TABLE IF NOT EXISTS blocked_numbers (
                number INTEGER PRIMARY KEY,
                label TEXT,
                source TEXT NOT NULL DEFAULT 'community',
                added_at REAL NOT NULL
            )
            """)
        execute("""
            CREATE TABLE IF NOT EXISTS identification_entries (
                number INTEGER PRIMARY KEY,
                label TEXT NOT NULL
            )
            """)
        execute("""
            CREATE INDEX IF NOT EXISTS idx_blocked_source ON blocked_numbers(source)
            """)
    }

    private func execute(_ sql: String) {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }

    func addBlockedNumber(_ number: Int64, label: String? = nil, source: BlockedNumber.BlockSource = .custom) {
        let sql = "INSERT OR REPLACE INTO blocked_numbers (number, label, source, added_at) VALUES (?, ?, ?, ?)"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        sqlite3_bind_int64(stmt, 1, number)
        if let label { sqlite3_bind_text(stmt, 2, (label as NSString).utf8String, -1, nil) }
        else { sqlite3_bind_null(stmt, 2) }
        sqlite3_bind_text(stmt, 3, (source.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_double(stmt, 4, Date().timeIntervalSince1970)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }

    func removeBlockedNumber(_ number: Int64) {
        let sql = "DELETE FROM blocked_numbers WHERE number = ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        sqlite3_bind_int64(stmt, 1, number)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }

    func addIdentificationEntry(_ number: Int64, label: String) {
        let sql = "INSERT OR REPLACE INTO identification_entries (number, label) VALUES (?, ?)"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        sqlite3_bind_int64(stmt, 1, number)
        sqlite3_bind_text(stmt, 2, (label as NSString).utf8String, -1, nil)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }

    func fetchAllBlockedNumbers() -> [Int64] {
        var numbers: [Int64] = []
        let sql = "SELECT number FROM blocked_numbers ORDER BY number"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return numbers }
        while sqlite3_step(stmt) == SQLITE_ROW {
            numbers.append(sqlite3_column_int64(stmt, 0))
        }
        sqlite3_finalize(stmt)
        return numbers
    }

    func fetchAllIdentificationEntries() -> [IdentificationEntry] {
        var entries: [IdentificationEntry] = []
        let sql = "SELECT number, label FROM identification_entries ORDER BY number"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return entries }
        while sqlite3_step(stmt) == SQLITE_ROW {
            let number = sqlite3_column_int64(stmt, 0)
            let label = String(cString: sqlite3_column_text(stmt, 1))
            entries.append(IdentificationEntry(number: number, label: label))
        }
        sqlite3_finalize(stmt)
        return entries
    }

    func fetchBlockedNumbers(source: BlockedNumber.BlockSource) -> [BlockedNumber] {
        var numbers: [BlockedNumber] = []
        let sql = "SELECT number, label, source, added_at FROM blocked_numbers WHERE source = ? ORDER BY number"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return numbers }
        sqlite3_bind_text(stmt, 1, (source.rawValue as NSString).utf8String, -1, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            let number = sqlite3_column_int64(stmt, 0)
            let label: String? = {
                if sqlite3_column_type(stmt, 1) != SQLITE_NULL {
                    return String(cString: sqlite3_column_text(stmt, 1))
                }
                return nil
            }()
            let sourceStr = String(cString: sqlite3_column_text(stmt, 2))
            let addedAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 3))
            numbers.append(BlockedNumber(
                id: number,
                number: number,
                label: label,
                source: BlockedNumber.BlockSource(rawValue: sourceStr) ?? .custom,
                addedAt: addedAt
            ))
        }
        sqlite3_finalize(stmt)
        return numbers
    }

    func searchNumber(_ query: String) -> [BlockedNumber] {
        var numbers: [BlockedNumber] = []
        let sql = "SELECT number, label, source, added_at FROM blocked_numbers WHERE CAST(number AS TEXT) LIKE ? ORDER BY number LIMIT 50"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return numbers }
        sqlite3_bind_text(stmt, 1, ("\(query)%" as NSString).utf8String, -1, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            let number = sqlite3_column_int64(stmt, 0)
            let label: String? = {
                if sqlite3_column_type(stmt, 1) != SQLITE_NULL {
                    return String(cString: sqlite3_column_text(stmt, 1))
                }
                return nil
            }()
            let sourceStr = String(cString: sqlite3_column_text(stmt, 2))
            let addedAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 3))
            numbers.append(BlockedNumber(
                id: number,
                number: number,
                label: label,
                source: BlockedNumber.BlockSource(rawValue: sourceStr) ?? .custom,
                addedAt: addedAt
            ))
        }
        sqlite3_finalize(stmt)
        return numbers
    }

    func deleteAllCommunityNumbers() {
        execute("DELETE FROM blocked_numbers WHERE source = 'community'")
    }

    func blockedCount() -> Int {
        var count: Int = 0
        let sql = "SELECT COUNT(*) FROM blocked_numbers"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return count }
        if sqlite3_step(stmt) == SQLITE_ROW {
            count = Int(sqlite3_column_int(stmt, 0))
        }
        sqlite3_finalize(stmt)
        return count
    }

    func fetchSnapshot() -> BlocklistSnapshot {
        let blockedNumbers = fetchAllBlockedNumbers()
        let identificationEntries = fetchAllIdentificationEntries()
        return BlocklistSnapshot(
            blockedNumbers: blockedNumbers,
            identificationEntries: identificationEntries
        )
    }

    deinit {
        sqlite3_close(db)
    }
}
