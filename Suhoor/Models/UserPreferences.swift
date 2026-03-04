import Foundation

/// Notification and preference settings backed by shared UserDefaults (app group).
///
/// Uses the app group `group.com.chadnewbry.suhoor` so preferences are accessible
/// from the main app, widgets, and extensions.
@Observable
final class UserPreferences {

    static let shared = UserPreferences()

    @ObservationIgnored
    private let defaults: UserDefaults

    // MARK: - Azan Master Toggle

    /// Master toggle for all azan notifications.
    var azanNotificationsEnabled: Bool {
        get { defaults.object(forKey: "azanNotificationsEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "azanNotificationsEnabled") }
    }

    // MARK: - Individual Prayer Toggles

    var fajrAzan: Bool {
        get { defaults.object(forKey: "fajrAzan") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "fajrAzan") }
    }

    var dhuhrAzan: Bool {
        get { defaults.object(forKey: "dhuhrAzan") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "dhuhrAzan") }
    }

    var asrAzan: Bool {
        get { defaults.object(forKey: "asrAzan") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "asrAzan") }
    }

    var maghribAzan: Bool {
        get { defaults.object(forKey: "maghribAzan") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "maghribAzan") }
    }

    var ishaAzan: Bool {
        get { defaults.object(forKey: "ishaAzan") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "ishaAzan") }
    }

    // MARK: - Pre-Sehri Alarm

    /// Whether the pre-sehri (imsak) alarm is enabled.
    var preSehriAlarmEnabled: Bool {
        get { defaults.object(forKey: "preSehriAlarmEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "preSehriAlarmEnabled") }
    }

    /// Minutes before Fajr for the pre-sehri alarm. Options: 15, 30, 45, 60.
    var preSehriMinutesBefore: Int {
        get { defaults.object(forKey: "preSehriMinutesBefore") as? Int ?? 30 }
        set { defaults.set(newValue, forKey: "preSehriMinutesBefore") }
    }

    /// Valid options for pre-sehri minutes.
    static let preSehriMinutesOptions = [15, 30, 45, 60]

    // MARK: - Iftar

    /// 10-minute warning before Maghrib/Iftar.
    var iftarWarningEnabled: Bool {
        get { defaults.object(forKey: "iftarWarningEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "iftarWarningEnabled") }
    }

    /// Dua notification at exact Maghrib time.
    var iftarDuaEnabled: Bool {
        get { defaults.object(forKey: "iftarDuaEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "iftarDuaEnabled") }
    }

    // MARK: - Quran Reminder

    var quranReminderEnabled: Bool {
        get { defaults.object(forKey: "quranReminderEnabled") as? Bool ?? false }
        set { defaults.set(newValue, forKey: "quranReminderEnabled") }
    }

    /// Time for the daily Quran reading reminder (default 9 PM).
    var quranReminderTime: Date {
        get {
            if let interval = defaults.object(forKey: "quranReminderTime") as? TimeInterval {
                return Date(timeIntervalSinceReferenceDate: interval)
            }
            // Default: 9 PM today
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 21
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }
        set { defaults.set(newValue.timeIntervalSinceReferenceDate, forKey: "quranReminderTime") }
    }

    // MARK: - Hydration Reminders

    /// Post-iftar hydration reminders between iftar and sehri.
    var hydrationRemindersEnabled: Bool {
        get { defaults.object(forKey: "hydrationRemindersEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "hydrationRemindersEnabled") }
    }

    /// Interval in minutes between hydration reminders.
    var hydrationIntervalMinutes: Int {
        get { defaults.object(forKey: "hydrationIntervalMinutes") as? Int ?? 30 }
        set { defaults.set(newValue, forKey: "hydrationIntervalMinutes") }
    }

    // MARK: - Azan Reciter

    /// Sound name for azan notifications. Maps to a .caf file in the bundle.
    var selectedAzanReciter: String {
        get { defaults.string(forKey: "selectedAzanReciter") ?? "Default" }
        set { defaults.set(newValue, forKey: "selectedAzanReciter") }
    }

    /// Available azan reciter options.
    static let azanReciterOptions = ["Default", "Makkah"]

    // MARK: - Init

    private init() {
        defaults = UserDefaults(suiteName: "group.com.chadnewbry.suhoor") ?? .standard
    }
}
