import Foundation

/// Shared data container for App Group communication between main app, widgets, and Live Activities
struct SharedData: Codable {
    let nextPrayerName: String
    let nextPrayerTime: Date
    let iftarTime: Date
    let sehriTime: Date
    let ramadanDay: Int
    let fastingStreak: Int
    let quranProgress: Double // 0.0 - 1.0
    let upcomingPrayers: [SharedPrayerEntry]
    let lastUpdated: Date
    
    struct SharedPrayerEntry: Codable, Identifiable {
        var id: String { name }
        let name: String
        let emoji: String
        let time: Date
        let isPassed: Bool
    }
    
    static let suiteName = "group.com.chadnewbry.suhoor"
    static let storageKey = "shared_data"
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults(suiteName: Self.suiteName)?.set(data, forKey: Self.storageKey)
        }
    }
    
    static func load() -> SharedData? {
        guard let data = UserDefaults(suiteName: suiteName)?.data(forKey: storageKey),
              let shared = try? JSONDecoder().decode(SharedData.self, from: data) else {
            return nil
        }
        return shared
    }
    
    static var placeholder: SharedData {
        let now = Date()
        let cal = Calendar.current
        return SharedData(
            nextPrayerName: "Maghrib",
            nextPrayerTime: cal.date(byAdding: .hour, value: 2, to: now)!,
            iftarTime: cal.date(byAdding: .hour, value: 2, to: now)!,
            sehriTime: cal.date(byAdding: .hour, value: 10, to: now)!,
            ramadanDay: 15,
            fastingStreak: 14,
            quranProgress: 0.5,
            upcomingPrayers: [
                SharedPrayerEntry(name: "Maghrib", emoji: "🌇", time: cal.date(byAdding: .hour, value: 2, to: now)!, isPassed: false),
                SharedPrayerEntry(name: "Isha", emoji: "🌙", time: cal.date(byAdding: .hour, value: 3, to: now)!, isPassed: false),
                SharedPrayerEntry(name: "Fajr", emoji: "🌅", time: cal.date(byAdding: .hour, value: 12, to: now)!, isPassed: false),
            ],
            lastUpdated: now
        )
    }
}
