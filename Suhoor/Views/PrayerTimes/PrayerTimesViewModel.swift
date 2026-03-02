import SwiftUI
import Combine
import CoreLocation

@MainActor
final class PrayerTimesViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var now: Date = Date()
    @Published var dailyPrayers: DailyPrayerTimes?
    @Published var azanToggles: [PrayerName: Bool] = [:]

    private var timer: AnyCancellable?
    private let hijri = HijriCalendarService.shared
    private let settings = UserSettings.shared

    var allPrayers: [PrayerTime] {
        dailyPrayers?.allPrayers ?? []
    }

    var imsakTime: Date? { dailyPrayers?.imsak }
    var iftarTime: Date? { dailyPrayers?.iftar }
    var taraweehTime: Date? { dailyPrayers?.taraweeh }

    var isRamadan: Bool {
        hijri.isRamadan(date: selectedDate, adjustment: settings.hijriAdjustment)
    }

    var hijriDateString: String {
        hijri.hijriDateString(from: selectedDate, adjustment: settings.hijriAdjustment)
    }

    var gregorianDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f.string(from: selectedDate)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var nextPrayer: PrayerTime? {
        guard isToday else { return nil }
        return allPrayers.first { $0.time > now }
    }

    init() {
        loadToggles()
        recalculate()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in self?.now = date }
    }

    func navigateDay(by offset: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) else { return }
        selectedDate = newDate
        recalculate()
    }

    func recalculate() {
        guard let location = settings.selectedLocation else { return }
        let coord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let tz = location.timeZone ?? .current
        dailyPrayers = PrayerTimesCalculator.shared.calculate(
            for: selectedDate, coordinate: coord, timeZone: tz,
            method: settings.calculationMethod, madhhab: settings.madhhab
        )
    }

    func isAzanEnabled(for prayer: PrayerName) -> Bool {
        azanToggles[prayer] ?? true
    }

    func toggleAzan(for prayer: PrayerName) {
        let current = azanToggles[prayer] ?? true
        azanToggles[prayer] = !current
        saveToggles()
    }

    private func loadToggles() {
        for prayer in PrayerName.allCases {
            let key = "azan_\(prayer.rawValue)"
            azanToggles[prayer] = UserDefaults.standard.object(forKey: key) as? Bool ?? true
        }
    }

    private func saveToggles() {
        for (prayer, enabled) in azanToggles {
            UserDefaults.standard.set(enabled, forKey: "azan_\(prayer.rawValue)")
        }
    }
}
