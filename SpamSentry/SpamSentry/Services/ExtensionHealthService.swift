import CallKit
import Foundation

final class ExtensionHealthService {
    static let shared = ExtensionHealthService()

    enum HealthStatus {
        case healthy
        case stale(lastLoad: Date)
        case failed(error: String)
        case disabled
        case unknown
    }

    private init() {}

    func checkHealth() async -> HealthStatus {
        guard SpamSentryShared.isEnabled else { return .disabled }

        if let error = SpamSentryShared.lastExtensionError {
            return .failed(error: error)
        }

        guard let lastLoad = SpamSentryShared.lastExtensionLoadDate else {
            return .unknown
        }

        let hoursSinceLastLoad = Date().timeIntervalSince(lastLoad) / 3600

        if hoursSinceLastLoad > 24 {
            return .stale(lastLoad: lastLoad)
        }

        return .healthy
    }

    func verifyExtensionStatus() async -> Bool {
        do {
            let status = try await CXCallDirectoryManager.sharedInstance
                .enabledStatusForExtension(
                    withIdentifier: SpamSentryShared.callBlockerExtensionId
                )
            return status == .enabled
        } catch {
            return false
        }
    }

    func repairIfNeeded() async throws {
        let health = await checkHealth()

        switch health {
        case .stale, .unknown, .failed:
            try await reloadExtension()
        case .disabled:
            break
        case .healthy:
            break
        }
    }

    func reloadExtension() async throws {
        try await CXCallDirectoryManager.sharedInstance
            .reloadExtension(
                withIdentifier: SpamSentryShared.callBlockerExtensionId
            )
    }
}
