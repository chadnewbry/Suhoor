import Foundation
import SwiftUI

// MARK: - Calculation Method

enum CalculationMethod: String, Codable, CaseIterable, Identifiable {
    case muslimWorldLeague = "Muslim World League"
    case egyptian = "Egyptian General Authority"
    case karachi = "University of Islamic Sciences, Karachi"
    case ummAlQura = "Umm Al-Qura University, Makkah"
    case dubai = "Dubai"
    case qatar = "Qatar"
    case kuwait = "Kuwait"
    case moonsightingCommittee = "Moonsighting Committee"
    case singapore = "Singapore"
    case turkey = "Turkey (Diyanet)"
    case tehran = "Tehran"
    case northAmerica = "ISNA (North America)"

    var id: String { rawValue }
}

// MARK: - Madhhab

enum Madhhab: String, Codable, CaseIterable, Identifiable {
    case shafi = "Shafi"
    case hanafi = "Hanafi"

    var id: String { rawValue }
}

// MARK: - App Language

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case arabic = "ar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        }
    }
}

// MARK: - Color Theme

enum ColorTheme: String, Codable, CaseIterable, Identifiable {
    case gold
    case emerald
    case sapphire
    case rose

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }
}

// MARK: - User Settings (AppStorage-backed)

@Observable
final class UserSettings {
    static let shared = UserSettings()

    @ObservationIgnored
    private let defaults = UserDefaults.standard

    var calculationMethod: CalculationMethod {
        get { CalculationMethod(rawValue: defaults.string(forKey: "calculationMethod") ?? "") ?? .northAmerica }
        set { defaults.set(newValue.rawValue, forKey: "calculationMethod") }
    }

    var madhhab: Madhhab {
        get { Madhhab(rawValue: defaults.string(forKey: "madhhab") ?? "") ?? .shafi }
        set { defaults.set(newValue.rawValue, forKey: "madhhab") }
    }

    var language: AppLanguage {
        get { AppLanguage(rawValue: defaults.string(forKey: "language") ?? "") ?? .english }
        set { defaults.set(newValue.rawValue, forKey: "language") }
    }

    var colorTheme: ColorTheme {
        get { ColorTheme(rawValue: defaults.string(forKey: "colorTheme") ?? "") ?? .gold }
        set { defaults.set(newValue.rawValue, forKey: "colorTheme") }
    }

    var preSehriAlarmMinutes: Int {
        get { defaults.object(forKey: "preSehriAlarmMinutes") as? Int ?? 30 }
        set { defaults.set(newValue, forKey: "preSehriAlarmMinutes") }
    }

    var isMenstrualModeEnabled: Bool {
        get { defaults.bool(forKey: "isMenstrualModeEnabled") }
        set { defaults.set(newValue, forKey: "isMenstrualModeEnabled") }
    }

    var hijriAdjustment: Int {
        get { defaults.object(forKey: "hijriAdjustment") as? Int ?? 0 }
        set { defaults.set(newValue, forKey: "hijriAdjustment") }
    }

    var selectedLocation: LocationData? {
        get {
            guard let data = defaults.data(forKey: "selectedLocation") else { return nil }
            return try? JSONDecoder().decode(LocationData.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: "selectedLocation")
            } else {
                defaults.removeObject(forKey: "selectedLocation")
            }
        }
    }

    var isHealthKitEnabled: Bool {
        get { defaults.bool(forKey: "isHealthKitEnabled") }
        set { defaults.set(newValue, forKey: "isHealthKitEnabled") }
    }

    // MARK: - Notification Preferences

    var fajrNotification: Bool {
        get { defaults.object(forKey: "notify_fajr") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notify_fajr") }
    }

    var dhuhrNotification: Bool {
        get { defaults.object(forKey: "notify_dhuhr") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notify_dhuhr") }
    }

    var asrNotification: Bool {
        get { defaults.object(forKey: "notify_asr") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notify_asr") }
    }

    var maghribNotification: Bool {
        get { defaults.object(forKey: "notify_maghrib") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notify_maghrib") }
    }

    var ishaNotification: Bool {
        get { defaults.object(forKey: "notify_isha") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notify_isha") }
    }

    var suhoorNotification: Bool {
        get { defaults.object(forKey: "notify_suhoor") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notify_suhoor") }
    }

    var iftarNotification: Bool {
        get { defaults.object(forKey: "notify_iftar") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notify_iftar") }
    }

    private init() {}
}
