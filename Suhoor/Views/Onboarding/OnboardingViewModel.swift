import SwiftUI
import UserNotifications

@MainActor
@Observable
final class OnboardingViewModel {
    // MARK: - Page State

    enum Page: Int, CaseIterable {
        case welcome = 0
        case location
        case calculationMethod
        case madhhab
        case notifications
        case language
        case menstrualMode
    }

    var currentPage: Page = .welcome
    var direction: Edge = .trailing

    var totalPages: Int { Page.allCases.count }
    var currentIndex: Int { currentPage.rawValue }

    // MARK: - Location

    let locationService = LocationService.shared
    var citySearchText = ""
    var searchResult: LocationData?
    var isSearching = false
    var selectedLocation: LocationData?

    // MARK: - Preferences

    var calculationMethod: CalculationMethod = .northAmerica
    var madhhab: Madhhab = .shafi
    var language: AppLanguage = .systemDefault

    // MARK: - Notifications

    var suhoorNotification = true
    var prayerTimesNotification = true
    var iftarNotification = true
    var quranReminderNotification = true

    // MARK: - Menstrual

    var menstrualModeEnabled = false

    // MARK: - Navigation

    func advance() {
        guard let next = Page(rawValue: currentPage.rawValue + 1) else {
            completeOnboarding()
            return
        }
        direction = .trailing
        withAnimation(.easeInOut(duration: 0.35)) {
            currentPage = next
        }
    }

    func goBack() {
        guard let prev = Page(rawValue: currentPage.rawValue - 1) else { return }
        direction = .leading
        withAnimation(.easeInOut(duration: 0.35)) {
            currentPage = prev
        }
    }

    // MARK: - Location Actions

    func requestLocation() {
        locationService.requestPermission()
    }

    func searchCity() async {
        guard !citySearchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        searchResult = await locationService.geocode(query: citySearchText)
        isSearching = false
        if let result = searchResult {
            selectedLocation = result
        }
    }

    func useDetectedLocation() {
        selectedLocation = locationService.detectedLocationData
        if let countryCode = locationService.currentPlacemark?.isoCountryCode {
            calculationMethod = .suggested(forCountryCode: countryCode)
        }
    }

    // MARK: - Notifications

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    // MARK: - Complete

    func completeOnboarding() {
        let settings = UserSettings.shared
        settings.selectedLocation = selectedLocation
        settings.calculationMethod = calculationMethod
        settings.madhhab = madhhab
        settings.language = language
        settings.suhoorNotification = suhoorNotification
        settings.fajrNotification = prayerTimesNotification
        settings.dhuhrNotification = prayerTimesNotification
        settings.asrNotification = prayerTimesNotification
        settings.maghribNotification = prayerTimesNotification
        settings.ishaNotification = prayerTimesNotification
        settings.iftarNotification = iftarNotification
        settings.quranReminderNotification = quranReminderNotification
        settings.isMenstrualModeEnabled = menstrualModeEnabled
        settings.hasCompletedOnboarding = true
    }
}
