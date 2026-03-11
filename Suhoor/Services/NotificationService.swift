import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    func checkPermission() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }
    
    // MARK: - Schedule All
    
    func scheduleAllNotifications(for prayerTimes: DailyPrayerTimes, settings: NotificationSettings) async {
        // Remove existing scheduled notifications
        center.removeAllPendingNotificationRequests()
        
        // Schedule azan notifications
        for prayer in Prayer.allCases where prayer.hasAzan {
            if settings.azanEnabled[prayer.rawValue] == true {
                let soundName = settings.azanSound[prayer.rawValue] ?? AzanSound.makkah.rawValue
                scheduleAzanNotification(prayer: prayer, time: prayerTimes.time(for: prayer), soundName: soundName)
            }
        }
        
        // Pre-sehri alarm
        if settings.preSehriAlarmEnabled {
            let alarmTime = Calendar.current.date(byAdding: .minute, value: -settings.preSehriMinutesBefore, to: prayerTimes.sehriTime)!
            scheduleNotification(
                id: "pre-sehri",
                title: "Sehri Wake Up ⏰",
                body: "Sehri is in \(settings.preSehriMinutesBefore) minutes. Time to eat!",
                date: alarmTime,
                sound: .defaultCritical,
                interruptionLevel: .timeSensitive
            )
        }
        
        // 10-minute iftar warning
        if settings.iftarWarningEnabled {
            let warningTime = Calendar.current.date(byAdding: .minute, value: -settings.iftarWarningMinutes, to: prayerTimes.iftarTime)!
            scheduleNotification(
                id: "iftar-warning",
                title: "Iftar Soon 🌙",
                body: "Iftar in \(settings.iftarWarningMinutes) minutes!",
                date: warningTime,
                sound: .default,
                interruptionLevel: .timeSensitive
            )
        }
        
        // Iftar time
        if settings.iftarTimeEnabled {
            scheduleNotification(
                id: "iftar-time",
                title: "It's Iftar Time! 🤲",
                body: "اللَّهُمَّ إِنِّي لَكَ صُمْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ\nO Allah, I fasted for You and I break my fast with Your provision.",
                date: prayerTimes.iftarTime,
                sound: .default,
                interruptionLevel: .timeSensitive
            )
        }
        
        // Quran reading reminder
        if settings.quranReminderEnabled {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: settings.quranReminderTime)
            scheduleRepeatingNotification(
                id: "quran-reminder",
                title: "Quran Reading Time 📖",
                body: "Take a few minutes to read Quran today.",
                hour: comps.hour ?? 21,
                minute: comps.minute ?? 0
            )
        }
        
        // Fasting log reminder
        if settings.fastingLogReminderEnabled {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: settings.fastingLogReminderTime)
            scheduleRepeatingNotification(
                id: "fasting-log",
                title: "Log Your Fast 📝",
                body: "Don't forget to log today's fast!",
                hour: comps.hour ?? 21,
                minute: comps.minute ?? 30
            )
        }
    }
    
    // MARK: - Individual Schedulers
    
    private func scheduleAzanNotification(prayer: Prayer, time: Date, soundName: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(prayer.emoji) \(prayer.displayName) Azan"
        content.body = "It's time for \(prayer.displayName) prayer."
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(soundName).caf"))
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "AZAN"
        
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        
        let request = UNNotificationRequest(identifier: "azan-\(prayer.rawValue)", content: content, trigger: trigger)
        center.add(request)
    }
    
    private func scheduleNotification(id: String, title: String, body: String, date: Date, sound: UNNotificationSound, interruptionLevel: UNNotificationInterruptionLevel) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        content.interruptionLevel = interruptionLevel
        
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
    
    private func scheduleRepeatingNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
    
    // MARK: - Cleanup
    
    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}

// MARK: - Public Scheduling for Suhoor Planning

extension NotificationService {
    func scheduleNotification(id: String, title: String, body: String, date: Date) async {
        scheduleNotification(id: id, title: title, body: body, date: date, sound: .default, interruptionLevel: .active)
    }
    
    func removeNotifications(withPrefix prefix: String) {
        center.getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
