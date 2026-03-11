import Foundation

struct NotificationSettings: Codable {
    var azanEnabled: [String: Bool] = Dictionary(uniqueKeysWithValues: Prayer.allCases.filter(\.hasAzan).map { ($0.rawValue, true) })
    var azanSound: [String: String] = Dictionary(uniqueKeysWithValues: Prayer.allCases.filter(\.hasAzan).map { ($0.rawValue, "azan_makkah") })
    var preSehriAlarmEnabled: Bool = true
    var preSehriMinutesBefore: Int = 30
    var iftarWarningEnabled: Bool = true
    var iftarWarningMinutes: Int = 10
    var iftarTimeEnabled: Bool = true
    var quranReminderEnabled: Bool = true
    var quranReminderTime: Date = {
        var comps = DateComponents()
        comps.hour = 21
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()
    var fastingLogReminderEnabled: Bool = true
    var fastingLogReminderTime: Date = {
        var comps = DateComponents()
        comps.hour = 21
        comps.minute = 30
        return Calendar.current.date(from: comps) ?? Date()
    }()
    
    static let storageKey = "notification_settings"
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults(suiteName: "group.com.chadnewbry.suhoor")?.set(data, forKey: Self.storageKey)
        }
    }
    
    static func load() -> NotificationSettings {
        guard let data = UserDefaults(suiteName: "group.com.chadnewbry.suhoor")?.data(forKey: storageKey),
              let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
            return NotificationSettings()
        }
        return settings
    }
}

enum AzanSound: String, CaseIterable, Identifiable {
    case makkah = "azan_makkah"
    case madinah = "azan_madinah"
    case alaqsa = "azan_alaqsa"
    case mishary = "azan_mishary"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .makkah: return "Makkah"
        case .madinah: return "Madinah"
        case .alaqsa: return "Al-Aqsa"
        case .mishary: return "Mishary Rashid"
        }
    }
    
    var fileName: String { rawValue }
}
