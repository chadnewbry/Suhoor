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
    case jafari = "Jafari (Shia Ithna-Ashari)"

    var id: String { rawValue }

    var shortDescription: String {
        switch self {
        case .northAmerica: return "Used in North America"
        case .muslimWorldLeague: return "Europe, Far East, parts of USA"
        case .egyptian: return "Africa, Syria, Iraq, Lebanon"
        case .karachi: return "Pakistan, Bangladesh, India, Afghanistan"
        case .ummAlQura: return "Arabian Peninsula"
        case .dubai: return "UAE"
        case .qatar: return "Qatar"
        case .kuwait: return "Kuwait"
        case .moonsightingCommittee: return "Moonsighting Committee Worldwide"
        case .singapore: return "Singapore, Malaysia, Indonesia"
        case .turkey: return "Turkey"
        case .tehran: return "Iran"
        case .jafari: return "Shia communities"
        }
    }

    /// Suggest a method based on ISO country code
    static func suggested(forCountryCode code: String?) -> CalculationMethod {
        guard let code = code?.uppercased() else { return .northAmerica }
        switch code {
        case "US", "CA": return .northAmerica
        case "EG", "SY", "IQ", "LB": return .egyptian
        case "PK", "BD", "IN", "AF": return .karachi
        case "SA": return .ummAlQura
        case "AE": return .dubai
        case "QA": return .qatar
        case "KW": return .kuwait
        case "SG": return .singapore
        case "MY", "ID": return .singapore
        case "TR": return .turkey
        case "IR": return .tehran
        default: return .muslimWorldLeague
        }
    }
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
    case urdu = "ur"
    case turkish = "tr"
    case malay = "ms"
    case indonesian = "id"
    case french = "fr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        case .urdu: return "اردو"
        case .turkish: return "Türkçe"
        case .malay: return "Bahasa Melayu"
        case .indonesian: return "Bahasa Indonesia"
        case .french: return "Français"
        }
    }

    /// Best guess based on system locale
    static var systemDefault: AppLanguage {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return AppLanguage(rawValue: code) ?? .english
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

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: "hasCompletedOnboarding") }
        set { defaults.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    var quranReminderNotification: Bool {
        get { defaults.object(forKey: "notify_quran") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notify_quran") }
    }

    private init() {}
}
