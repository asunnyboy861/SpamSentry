import Foundation
import UserNotifications

actor NotificationService {
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func sendBlockNotification(number: String) {
        let content = UNMutableNotificationContent()
        content.title = "Spam Call Blocked"
        content.body = "Blocked call from \(number)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
