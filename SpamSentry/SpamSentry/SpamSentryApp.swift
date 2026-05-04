import SwiftUI

@main
struct SpamSentryApp: App {
    init() {
        SpamSentryShared.registerDefaults()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
