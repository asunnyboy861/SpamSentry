import CallKit
import Foundation

final class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        if context.isIncremental {
            context.removeAllBlockingEntries()
            context.removeAllIdentificationEntries()
        }

        guard SpamSentryShared.isEnabled && !SpamSentryShared.isPaused else {
            context.completeRequest()
            return
        }

        let db = BlocklistDatabase.shared
        let blockedNumbers = db.fetchAllBlockedNumbers()
        let identificationEntries = db.fetchAllIdentificationEntries()

        let customNumbers = SpamSentryShared.customBlocklist
        var allBlocked = Set(blockedNumbers)
        for number in customNumbers {
            allBlocked.insert(number)
        }

        for phoneNumber in allBlocked.sorted() {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }

        for entry in identificationEntries {
            context.addIdentificationEntry(
                withNextSequentialPhoneNumber: entry.number,
                label: entry.label
            )
        }

        SpamSentryShared.lastExtensionLoadDate = Date()
        SpamSentryShared.blockedNumberCount = allBlocked.count

        context.completeRequest()
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        NSLog("SpamSentry: Call directory request failed - \(error.localizedDescription)")
        SpamSentryShared.lastExtensionError = error.localizedDescription
    }
}
