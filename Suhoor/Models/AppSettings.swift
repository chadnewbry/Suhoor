import Foundation
import SwiftUI

// MARK: - Calculation Method

enum CalculationMethod: String, CaseIterable, Identifiable, Codable {
    case isna = "ISNA"
    case mwl = "MWL"
    case egyptian = "Egyptian"
    case ummAlQura = "Umm Al-Qura"
    case karachi = "Karachi"
    case tehran = "Tehran"
    case gulf = "Gulf"
    case kuwait = "Kuwait"
    case qatar = "Qatar"
    case singapore = "Singapore"
    case turkey = "Turkey"
    case northAmerica = "North America"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .isna: return "ISNA (Islamic Society of North America)"
        case .mwl: return "Muslim World League"
        case .egyptian: return "Egyptian General Authority"
        case .ummAlQura: return "Umm Al-Qura (Makkah)"
        case .karachi: return "University of Islamic Sciences, Karachi"
        case .tehran: return "Institute of Geophysics, Tehran"
        case .gulf: return "Gulf Region"
        case .kuwait: return "Kuwait"
        case .qatar: return "Qatar"
        case .singapore: return "Singapore"
        case .turkey: return "Diyanet İşleri Başkanlığı, Turkey"
        case .northAmerica: return "ISNA (North America)"
        }
    }
}

// MARK: - Madhhab

enum Madhhab: String, CaseIterable, Identifiable, Codable {
    case shafi = "Shafi"
    case hanafi = "Hanafi"

    var id: String { rawValue }
    var displayName: String { rawValue }
}

// MARK: - App Language

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
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
}

// MARK: - Color Theme

enum AppColorTheme: String, CaseIterable, Identifiable, Codable {
    case midnightBlue = "midnight_blue"
    case emerald = "emerald"
    case desertSand = "desert_sand"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .midnightBlue: return "Midnight Blue"
        case .emerald: return "Emerald"
        case .desertSand: return "Desert Sand"
        }
    }

    var previewColor: Color {
        switch self {
        case .midnightBlue: return Color(red: 0.08, green: 0.07, blue: 0.20)
        case .emerald: return Color(red: 0.05, green: 0.20, blue: 0.15)
        case .desertSand: return Color(red: 0.25, green: 0.18, blue: 0.10)
        }
    }
}

// MARK: - App Settings

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    private static let storageKey = "app_settings"
    private static let suiteName = "group.com.chadnewbry.suhoor"

    // Prayer Time Settings
    @Published var calculationMethod: CalculationMethod { didSet { save() } }
    @Published var madhhab: Madhhab { didSet { save() } }
    @Published var useCurrentLocation: Bool { didSet { save() } }
    @Published var manualLocationName: String { didSet { save() } }
    @Published var manualLatitude: Double { didSet { save() } }
    @Published var manualLongitude: Double { didSet { save() } }
    @Published var prayerTimeAdjustments: [String: Int] { didSet { save() } }

    // Fasting Settings
    @Published var menstrualModeEnabled: Bool { didSet { save() } }
    @Published var healthKitSyncEnabled: Bool { didSet { save() } }
    @Published var makeupFastRemindersEnabled: Bool { didSet { save() } }

    // Display Settings
    @Published var use24HourFormat: Bool { didSet { save() } }
    @Published var appLanguage: AppLanguage { didSet { save() } }
    @Published var colorTheme: AppColorTheme { didSet { save() } }
    @Published var hapticFeedbackEnabled: Bool { didSet { save() } }

    // iCloud Sync
    @Published var iCloudSyncEnabled: Bool { didSet { save() } }

    private init() {
        let stored = Self.loadStored()
        self.calculationMethod = stored.calculationMethod
        self.madhhab = stored.madhhab
        self.useCurrentLocation = stored.useCurrentLocation
        self.manualLocationName = stored.manualLocationName
        self.manualLatitude = stored.manualLatitude
        self.manualLongitude = stored.manualLongitude
        self.prayerTimeAdjustments = stored.prayerTimeAdjustments
        self.menstrualModeEnabled = stored.menstrualModeEnabled
        self.healthKitSyncEnabled = stored.healthKitSyncEnabled
        self.makeupFastRemindersEnabled = stored.makeupFastRemindersEnabled
        self.use24HourFormat = stored.use24HourFormat
        self.appLanguage = stored.appLanguage
        self.colorTheme = stored.colorTheme
        self.hapticFeedbackEnabled = stored.hapticFeedbackEnabled
        self.iCloudSyncEnabled = stored.iCloudSyncEnabled
    }

    func adjustmentMinutes(for prayer: Prayer) -> Int {
        prayerTimeAdjustments[prayer.rawValue] ?? 0
    }

    func setAdjustment(_ minutes: Int, for prayer: Prayer) {
        prayerTimeAdjustments[prayer.rawValue] = minutes
    }

    // MARK: - Persistence

    private struct StoredSettings: Codable {
        var calculationMethod: CalculationMethod = .isna
        var madhhab: Madhhab = .shafi
        var useCurrentLocation: Bool = true
        var manualLocationName: String = ""
        var manualLatitude: Double = 0
        var manualLongitude: Double = 0
        var prayerTimeAdjustments: [String: Int] = [:]
        var menstrualModeEnabled: Bool = false
        var healthKitSyncEnabled: Bool = false
        var makeupFastRemindersEnabled: Bool = false
        var use24HourFormat: Bool = false
        var appLanguage: AppLanguage = .english
        var colorTheme: AppColorTheme = .midnightBlue
        var hapticFeedbackEnabled: Bool = true
        var iCloudSyncEnabled: Bool = false
    }

    private func save() {
        let stored = StoredSettings(
            calculationMethod: calculationMethod,
            madhhab: madhhab,
            useCurrentLocation: useCurrentLocation,
            manualLocationName: manualLocationName,
            manualLatitude: manualLatitude,
            manualLongitude: manualLongitude,
            prayerTimeAdjustments: prayerTimeAdjustments,
            menstrualModeEnabled: menstrualModeEnabled,
            healthKitSyncEnabled: healthKitSyncEnabled,
            makeupFastRemindersEnabled: makeupFastRemindersEnabled,
            use24HourFormat: use24HourFormat,
            appLanguage: appLanguage,
            colorTheme: colorTheme,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            iCloudSyncEnabled: iCloudSyncEnabled
        )
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults(suiteName: Self.suiteName)?.set(data, forKey: Self.storageKey)
        }
    }

    private static func loadStored() -> StoredSettings {
        guard let data = UserDefaults(suiteName: suiteName)?.data(forKey: storageKey),
              let stored = try? JSONDecoder().decode(StoredSettings.self, from: data) else {
            return StoredSettings()
        }
        return stored
    }
}
