import Foundation
import UserNotifications

/// Manages all local notifications for prayer times, sehri/iftar alerts,
/// Quran reminders, and hydration reminders.
@MainActor
@Observable
final class NotificationManager {

    static let shared = NotificationManager()

    /// Current authorization status.
    private(set) var isAuthorized = false

    @ObservationIgnored
    private let center = UNUserNotificationCenter.current()

    @ObservationIgnored
    private let preferences = UserPreferences.shared

    // MARK: - Notification Identifiers

    private enum Identifier {
        static let azanPrefix = "suhoor.azan."
        static let preSehri = "suhoor.preSehri"
        static let iftarWarning = "suhoor.iftarWarning"
        static let iftarDua = "suhoor.iftarDua"
        static let quranReminder = "suhoor.quranReminder"
        static let hydrationPrefix = "suhoor.hydration."
    }

    // MARK: - Categories

    private enum Category {
        static let preSehriAlarm = "SUHOOR_PRE_SEHRI"
    }

    private enum Action {
        static let snooze = "SUHOOR_SNOOZE_5"
    }

    private init() {
        registerCategories()
    }

    // MARK: - Permission

    /// Request notification authorization from the user.
    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    /// Check current authorization status.
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Master Schedule

    /// Clears all pending notifications and reschedules everything based on current preferences.
    func scheduleAllNotifications() {
        cancelAllNotifications()

        let prayerTimes = SamplePrayerTimes.todayTimes()

        // Azan notifications
        if preferences.azanNotificationsEnabled {
            scheduleAzanNotifications(for: Date(), prayerTimes: prayerTimes)
        }

        // Pre-sehri alarm
        if preferences.preSehriAlarmEnabled {
            schedulePreSehriAlarm(
                fajrTime: prayerTimes.fajr,
                minutesBefore: preferences.preSehriMinutesBefore
            )
        }

        // Iftar warning (10 min before)
        if preferences.iftarWarningEnabled {
            scheduleIftarWarning(maghribTime: prayerTimes.maghrib)
        }

        // Iftar dua (at Maghrib)
        if preferences.iftarDuaEnabled {
            scheduleIftarDua(maghribTime: prayerTimes.maghrib)
        }

        // Quran reminder
        if preferences.quranReminderEnabled {
            scheduleQuranReminder(at: preferences.quranReminderTime)
        }

        // Hydration reminders
        if preferences.hydrationRemindersEnabled {
            scheduleHydrationReminders(
                iftarTime: prayerTimes.maghrib,
                sehriTime: prayerTimes.fajr,
                interval: preferences.hydrationIntervalMinutes
            )
        }
    }

    // MARK: - Azan Notifications

    /// Schedule azan notifications for each enabled prayer.
    func scheduleAzanNotifications(for date: Date, prayerTimes: SamplePrayerTimes) {
        let prayers: [(PrayerName, Date, Bool)] = [
            (.fajr, prayerTimes.fajr, preferences.fajrAzan),
            (.dhuhr, prayerTimes.dhuhr, preferences.dhuhrAzan),
            (.asr, prayerTimes.asr, preferences.asrAzan),
            (.maghrib, prayerTimes.maghrib, preferences.maghribAzan),
            (.isha, prayerTimes.isha, preferences.ishaAzan),
        ]

        let soundName = azanSoundName(for: preferences.selectedAzanReciter)

        for (prayer, time, enabled) in prayers where enabled {
            let content = UNMutableNotificationContent()
            content.title = "\(prayer.rawValue) Azan"
            content.body = "It's time for \(prayer.rawValue) prayer."
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
            content.categoryIdentifier = "SUHOOR_AZAN"

            let trigger = calendarTrigger(from: time)
            let id = "\(Identifier.azanPrefix)\(prayer.rawValue.lowercased())"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: - Pre-Sehri Alarm

    /// Schedule an alarm before Fajr with a snooze action.
    func schedulePreSehriAlarm(fajrTime: Date, minutesBefore: Int) {
        let alarmTime = fajrTime.addingTimeInterval(Double(-minutesBefore) * 60)

        let content = UNMutableNotificationContent()
        content.title = "Sehri Reminder"
        content.body = "Sehri ends in \(minutesBefore) minutes. Time to eat and hydrate!"
        content.sound = .defaultCritical
        content.categoryIdentifier = Category.preSehriAlarm

        let trigger = calendarTrigger(from: alarmTime)
        let request = UNNotificationRequest(identifier: Identifier.preSehri, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Iftar Warning

    /// Schedule a 10-minute warning before Maghrib/Iftar.
    func scheduleIftarWarning(maghribTime: Date) {
        let warningTime = maghribTime.addingTimeInterval(-10 * 60)

        let content = UNMutableNotificationContent()
        content.title = "Iftar in 10 Minutes"
        content.body = "Prepare for iftar. May Allah accept your fast!"
        content.sound = .default

        let trigger = calendarTrigger(from: warningTime)
        let request = UNNotificationRequest(identifier: Identifier.iftarWarning, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Iftar Dua

    /// Schedule the iftar dua notification at exact Maghrib time.
    func scheduleIftarDua(maghribTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Iftar Time — Break Your Fast"
        content.body = "ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ\n\n\"The thirst is gone, the veins are moistened, and the reward is assured, if Allah wills.\""
        content.sound = .default

        let trigger = calendarTrigger(from: maghribTime)
        let request = UNNotificationRequest(identifier: Identifier.iftarDua, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Quran Reminder

    /// Schedule a daily Quran reading reminder at the specified time.
    func scheduleQuranReminder(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Quran Reminder"
        content.body = "Time for your daily Quran reading. Even a few ayat make a difference."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Identifier.quranReminder, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Hydration Reminders

    /// Schedule hydration reminders between iftar and sehri at the given interval.
    func scheduleHydrationReminders(iftarTime: Date, sehriTime: Date, interval: Int) {
        // Hydration reminders run from iftar (today) to sehri (tomorrow).
        // We schedule starting 30 min after iftar to avoid overlap with iftar dua.
        var reminderTime = iftarTime.addingTimeInterval(30 * 60)

        // Sehri for tomorrow: add 1 day to the given fajr time
        let tomorrowSehri = sehriTime.addingTimeInterval(24 * 60 * 60)
        // Stop reminders 30 min before sehri
        let cutoff = tomorrowSehri.addingTimeInterval(-30 * 60)

        var index = 0
        while reminderTime < cutoff {
            let content = UNMutableNotificationContent()
            content.title = "Hydration Reminder 💧"
            content.body = "Drink a glass of water. Stay hydrated during Ramadan!"
            content.sound = .default

            let trigger = calendarTrigger(from: reminderTime)
            let id = "\(Identifier.hydrationPrefix)\(index)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)

            reminderTime = reminderTime.addingTimeInterval(Double(interval) * 60)
            index += 1

            // Safety cap: max 20 hydration reminders per night
            if index >= 20 { break }
        }
    }

    // MARK: - Cancel

    /// Remove all pending Suhoor notifications.
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - Handle Snooze Action

    /// Called from the app delegate / notification delegate to handle the snooze action.
    func handleSnoozeAction() {
        let snoozeTime = Date().addingTimeInterval(5 * 60)

        let content = UNMutableNotificationContent()
        content.title = "Sehri Reminder (Snoozed)"
        content.body = "Wake up! Sehri is ending soon."
        content.sound = .defaultCritical
        content.categoryIdentifier = Category.preSehriAlarm

        let trigger = calendarTrigger(from: snoozeTime)
        let request = UNNotificationRequest(identifier: "\(Identifier.preSehri).snooze", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Private Helpers

    /// Register notification categories with actions.
    private func registerCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: Action.snooze,
            title: "Snooze 5 min",
            options: []
        )

        let preSehriCategory = UNNotificationCategory(
            identifier: Category.preSehriAlarm,
            actions: [snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([preSehriCategory])
    }

    /// Build a calendar trigger from a specific date.
    private func calendarTrigger(from date: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    /// Map reciter name to .caf sound file name.
    private func azanSoundName(for reciter: String) -> String {
        switch reciter {
        case "Makkah": return "azan_makkah.caf"
        default: return "azan_default.caf"
        }
    }
}

// MARK: - Sample Prayer Times

/// Placeholder prayer times for Ramadan until a real API is integrated.
struct SamplePrayerTimes {
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date

    /// Generate sample prayer times for today using typical Ramadan times.
    static func todayTimes() -> SamplePrayerTimes {
        let cal = Calendar.current
        let today = Date()

        func time(hour: Int, minute: Int) -> Date {
            var components = cal.dateComponents([.year, .month, .day], from: today)
            components.hour = hour
            components.minute = minute
            return cal.date(from: components) ?? today
        }

        return SamplePrayerTimes(
            fajr: time(hour: 5, minute: 15),
            sunrise: time(hour: 6, minute: 35),
            dhuhr: time(hour: 12, minute: 45),
            asr: time(hour: 16, minute: 15),
            maghrib: time(hour: 18, minute: 45),
            isha: time(hour: 20, minute: 15)
        )
    }
}
