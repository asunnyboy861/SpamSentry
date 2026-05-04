import Foundation
import Observation

@Observable
final class StatsViewModel {
    var totalBlocked: Int = 0
    var todayBlocked: Int = 0
    var communityCount: Int = 0
    var customCount: Int = 0
    var lastSyncDate: Date?

    func loadStats() {
        totalBlocked = SpamSentryShared.totalBlocked
        todayBlocked = SpamSentryShared.todayBlocked
        lastSyncDate = SpamSentryShared.lastSyncDate

        let db = BlocklistDatabase.shared
        communityCount = db.fetchBlockedNumbers(source: .community).count
        customCount = SpamSentryShared.customBlocklist.count
    }
}
