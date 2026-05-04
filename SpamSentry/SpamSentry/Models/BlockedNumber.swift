import Foundation

struct BlockedNumberItem: Identifiable, Hashable {
    let id: Int64
    let number: Int64
    let label: String?
    let source: String
    let addedAt: Date

    var displayNumber: String {
        let str = String(number)
        if str.count == 11 && str.hasPrefix("1") {
            let area = String(str[str.index(str.startIndex, offsetBy: 1)..<str.index(str.startIndex, offsetBy: 4)])
            let mid = String(str[str.index(str.startIndex, offsetBy: 4)..<str.index(str.startIndex, offsetBy: 7)])
            let end = String(str[str.index(str.startIndex, offsetBy: 7)...])
            return "(\(area)) \(mid)-\(end)"
        }
        return str
    }
}

struct StatsData {
    var totalBlocked: Int
    var todayBlocked: Int
    var communityCount: Int
    var customCount: Int
    var lastSyncDate: Date?
    var extensionHealthy: Bool
}
