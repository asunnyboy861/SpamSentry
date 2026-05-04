import Foundation

actor BlocklistSyncService {
    static let shared = BlocklistSyncService()

    private let blocklistURL = "https://raw.githubusercontent.com/ffimnsr/spam-sniper/main/blocklist/blocked.csv"

    private init() {}

    func syncCommunityBlocklist() async throws {
        guard let url = URL(string: blocklistURL) else { return }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { return }

        guard let content = String(data: data, encoding: .utf8) else { return }

        let db = BlocklistDatabase.shared
        db.deleteAllCommunityNumbers()

        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let parts = trimmed.split(separator: ",", maxSplits: 1)
            guard let numberStr = parts.first,
                  let number = Int64(numberStr) else { continue }

            let label = parts.count > 1 ? String(parts[1]) : nil
            db.addBlockedNumber(number, label: label, source: .community)
        }

        SpamSentryShared.lastSyncDate = Date()
        SpamSentryShared.blockedNumberCount = db.blockedCount()
    }

    func fetchSnapshot() throws -> BlocklistSnapshot {
        let db = BlocklistDatabase.shared
        var snapshot = db.fetchSnapshot()

        let customNumbers = SpamSentryShared.customBlocklist
        for number in customNumbers {
            if !snapshot.blockedNumbers.contains(number) {
                snapshot.blockedNumbers.append(number)
            }
        }

        let areaCodeRules = SpamSentryShared.areaCodeRules
        if !areaCodeRules.isEmpty {
            let allBlocked = db.fetchAllBlockedNumbers()
            for number in allBlocked {
                if !snapshot.blockedNumbers.contains(number) {
                    snapshot.blockedNumbers.append(number)
                }
            }
        }

        snapshot.blockedNumbers.sort()

        return snapshot
    }
}
