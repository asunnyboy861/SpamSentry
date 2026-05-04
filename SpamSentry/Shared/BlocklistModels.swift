import Foundation

struct BlockedNumber: Codable, Identifiable, Hashable {
    let id: Int64
    let number: Int64
    let label: String?
    let source: BlockSource
    let addedAt: Date

    enum BlockSource: String, Codable {
        case community
        case custom
        case areaCode
    }
}

struct IdentificationEntry: Codable {
    let number: Int64
    let label: String
}

struct BlocklistSnapshot {
    var blockedNumbers: [Int64]
    var identificationEntries: [IdentificationEntry]
}
