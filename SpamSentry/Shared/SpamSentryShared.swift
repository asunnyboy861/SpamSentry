import Foundation

enum SpamSentryShared {
    static let appGroupIdentifier = "group.com.zzoutuo.SpamSentry.shared"
    static let callBlockerExtensionId = "com.zzoutuo.SpamSentry.CallBlockerExtension"
    static let messageFilterExtensionId = "com.zzoutuo.SpamSentry.MessageFilterExtension"

    private static let isEnabledKey = "spamsentry.isEnabled"
    private static let blockedNumberCountKey = "spamsentry.blockedNumberCount"
    private static let lastExtensionLoadDateKey = "spamsentry.lastExtensionLoadDate"
    private static let lastExtensionErrorKey = "spamsentry.lastExtensionError"
    private static let lastSyncDateKey = "spamsentry.lastSyncDate"
    private static let customBlocklistKey = "spamsentry.customBlocklist"
    private static let areaCodeRulesKey = "spamsentry.areaCodeRules"
    private static let pauseUntilKey = "spamsentry.pauseUntil"
    private static let totalBlockedKey = "spamsentry.totalBlocked"
    private static let todayBlockedKey = "spamsentry.todayBlocked"
    private static let todayDateKey = "spamsentry.todayDate"

    static var isEnabled: Bool {
        get { sharedDefaults.object(forKey: isEnabledKey) == nil ? true : sharedDefaults.bool(forKey: isEnabledKey) }
        set { sharedDefaults.set(newValue, forKey: isEnabledKey) }
    }

    static var blockedNumberCount: Int {
        get { sharedDefaults.integer(forKey: blockedNumberCountKey) }
        set { sharedDefaults.set(newValue, forKey: blockedNumberCountKey) }
    }

    static var lastExtensionLoadDate: Date? {
        get { sharedDefaults.object(forKey: lastExtensionLoadDateKey) as? Date }
        set { sharedDefaults.set(newValue, forKey: lastExtensionLoadDateKey) }
    }

    static var lastExtensionError: String? {
        get { sharedDefaults.string(forKey: lastExtensionErrorKey) }
        set { sharedDefaults.set(newValue, forKey: lastExtensionErrorKey) }
    }

    static var lastSyncDate: Date? {
        get { sharedDefaults.object(forKey: lastSyncDateKey) as? Date }
        set { sharedDefaults.set(newValue, forKey: lastSyncDateKey) }
    }

    static var isPaused: Bool {
        guard let until = sharedDefaults.object(forKey: pauseUntilKey) as? Date else { return false }
        return until > Date()
    }

    static func pauseFor(minutes: Int) {
        let until = Calendar.current.date(byAdding: .minute, value: minutes, to: Date())
        sharedDefaults.set(until, forKey: pauseUntilKey)
    }

    static func resumeBlocking() {
        sharedDefaults.removeObject(forKey: pauseUntilKey)
    }

    static var customBlocklist: [Int64] {
        get {
            guard let data = sharedDefaults.data(forKey: customBlocklistKey),
                  let numbers = try? JSONDecoder().decode([Int64].self, from: data) else { return [] }
            return numbers
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                sharedDefaults.set(data, forKey: customBlocklistKey)
            }
        }
    }

    static var areaCodeRules: [String] {
        get { sharedDefaults.stringArray(forKey: areaCodeRulesKey) ?? [] }
        set { sharedDefaults.set(newValue, forKey: areaCodeRulesKey) }
    }

    static var totalBlocked: Int {
        get { sharedDefaults.integer(forKey: totalBlockedKey) }
        set { sharedDefaults.set(newValue, forKey: totalBlockedKey) }
    }

    static var todayBlocked: Int {
        get {
            let todayStr = Calendar.current.startOfDay(for: Date()).description
            if sharedDefaults.string(forKey: todayDateKey) == todayStr {
                return sharedDefaults.integer(forKey: todayBlockedKey)
            }
            return 0
        }
        set {
            let todayStr = Calendar.current.startOfDay(for: Date()).description
            sharedDefaults.set(todayStr, forKey: todayDateKey)
            sharedDefaults.set(newValue, forKey: todayBlockedKey)
        }
    }

    static func incrementBlocked() {
        totalBlocked += 1
        todayBlocked += 1
    }

    static func registerDefaults() {
        sharedDefaults.register(defaults: [isEnabledKey: true])
    }

    static var sharedDefaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            fatalError("Unable to create shared defaults for \(appGroupIdentifier)")
        }
        return defaults
    }
}
