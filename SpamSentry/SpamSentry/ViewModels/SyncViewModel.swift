import Foundation
import Observation

@Observable
final class SyncViewModel {
    var isSyncing = false
    var lastSyncDate: Date?
    var totalNumbers: Int = 0
    var errorMessage: String?

    func loadState() {
        lastSyncDate = SpamSentryShared.lastSyncDate
        totalNumbers = SpamSentryShared.blockedNumberCount
    }

    func syncBlocklist() async {
        isSyncing = true
        defer { isSyncing = false }

        do {
            try await BlocklistSyncService.shared.syncCommunityBlocklist()
            lastSyncDate = SpamSentryShared.lastSyncDate
            totalNumbers = SpamSentryShared.blockedNumberCount
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
