import Foundation
import SwiftUI

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
    @Published var appearanceMode: AppearanceMode { didSet { save() } }

    // Hijri
    @Published var hijriDateAdjustment: Int { didSet { save() } }

    // Hydration
    @Published var hydrationTarget: Int { didSet { save() } }

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
        self.hijriDateAdjustment = stored.hijriDateAdjustment
        self.hydrationTarget = stored.hydrationTarget
        self.appearanceMode = stored.appearanceMode
    }

    func adjustmentMinutes(for prayer: Prayer) -> Int {
        prayerTimeAdjustments[prayer.rawValue] ?? 0
    }

    func setAdjustment(_ minutes: Int, for prayer: Prayer) {
        prayerTimeAdjustments[prayer.rawValue] = minutes
    }

    // MARK: - Persistence

    private struct StoredSettings: Codable {
        var calculationMethod: CalculationMethod = .northAmerica
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
        var hijriDateAdjustment: Int = 0
        var hydrationTarget: Int = 8
        var appearanceMode: AppearanceMode = .dark
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
            iCloudSyncEnabled: iCloudSyncEnabled,
            hijriDateAdjustment: hijriDateAdjustment,
            hydrationTarget: hydrationTarget,
            appearanceMode: appearanceMode
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

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable, Identifiable, Codable {
    case dark = "dark"
    case light = "light"
    case auto = "auto"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        case .auto: return "Auto (System)"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .auto: return nil
        }
    }
}
