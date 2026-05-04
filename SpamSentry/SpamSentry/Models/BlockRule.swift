import Foundation

struct BlockRule: Identifiable, Hashable {
    let id = UUID()
    var type: RuleType
    var value: String
    var isEnabled: Bool

    enum RuleType: String, CaseIterable {
        case areaCode = "Area Code"
        case wildcard = "Wildcard"
        case exact = "Exact Number"
    }
}

struct SyncStatus {
    var lastSyncDate: Date?
    var totalNumbers: Int
    var isSyncing: Bool
    var error: String?
}
