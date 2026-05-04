import CallKit
import Foundation
import Observation
import UIKit

@Observable
final class BlockerViewModel {
    var isEnabled = true
    var isPaused = false
    var pauseMinutes: Int = 0
    var healthStatus: ExtensionHealthService.HealthStatus = .unknown
    var isExtensionEnabled = false
    var isLoading = false
    var errorMessage: String?

    private let healthService = ExtensionHealthService.shared

    func loadState() {
        isEnabled = SpamSentryShared.isEnabled
        isPaused = SpamSentryShared.isPaused
    }

    func toggleEnabled() {
        isEnabled.toggle()
        SpamSentryShared.isEnabled = isEnabled
    }

    func pauseBlocking(minutes: Int) {
        SpamSentryShared.pauseFor(minutes: minutes)
        isPaused = true
        pauseMinutes = minutes
    }

    func resumeBlocking() {
        SpamSentryShared.resumeBlocking()
        isPaused = false
        pauseMinutes = 0
    }

    func checkHealth() async {
        healthStatus = await healthService.checkHealth()
        isExtensionEnabled = await healthService.verifyExtensionStatus()
    }

    func repairExtension() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await healthService.repairIfNeeded()
            healthStatus = await healthService.checkHealth()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadExtension() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await healthService.reloadExtension()
            SpamSentryShared.lastExtensionError = nil
            healthStatus = await healthService.checkHealth()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openPhoneSettings() {
        if let url = URL(string: "App-prefs:root=Phone") {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
