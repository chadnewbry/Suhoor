import SwiftUI
import Combine
import CoreLocation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var now = Date()
    @Published var prayerTimes: [PrayerTime] = []
    @Published var fastingDay: FastingDay
    @Published var verse: QuranVerse
    @Published var deed: DeedOfTheDay
    @Published var fastsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    @Published var quranJuz: Int = 1
    @Published var deedsToday: Int = 0
    @Published var showAllPrayers: Bool = false

    private var timer: AnyCancellable?
    private let countdown = CountdownEngine.shared
    private let hijri = HijriCalendarService.shared

    var nextPrayer: PrayerTime? {
        prayerTimes.first { $0.time > now }
    }

    var countdownLabel: String {
        countdown.nextEvent?.label ?? fastingDay.timeToNextEvent(from: now).label
    }

    var countdownRemaining: TimeInterval {
        countdown.timeRemaining > 0 ? countdown.timeRemaining : fastingDay.timeToNextEvent(from: now).remaining
    }

    var countdownFormatted: (hours: String, minutes: String, seconds: String) {
        let cd = countdown.formattedCountdown
        if countdown.timeRemaining > 0 { return cd }
        let total = Int(max(countdownRemaining, 0))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return (String(format: "%02d", h), String(format: "%02d", m), String(format: "%02d", s))
    }

    var fastingProgress: Double {
        fastingDay.fastingProgress(at: now)
    }

    init() {
        let today = Date()
        let cal = Calendar.current
        let settings = UserSettings.shared

        // Try real calculation
        var sehri: Date
        var iftar: Date
        var prayers: [PrayerTime] = []

        if let location = settings.selectedLocation {
            let coord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let tz = location.timeZone ?? .current
            let daily = PrayerTimesCalculator.shared.calculate(
                for: today, coordinate: coord, timeZone: tz,
                method: settings.calculationMethod, madhhab: settings.madhhab
            )
            sehri = daily.imsak
            iftar = daily.iftar
            prayers = daily.allPrayers

            // Start countdown engine
            countdown.recalculate()
        } else {
            // Fallback placeholder
            func timeToday(_ hour: Int, _ minute: Int) -> Date {
                cal.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
            }
            sehri = timeToday(5, 15)
            iftar = timeToday(18, 32)
            prayers = [
                PrayerTime(name: .fajr, time: timeToday(5, 15)),
                PrayerTime(name: .sunrise, time: timeToday(6, 38)),
                PrayerTime(name: .dhuhr, time: timeToday(12, 15)),
                PrayerTime(name: .asr, time: timeToday(15, 42)),
                PrayerTime(name: .maghrib, time: timeToday(18, 32)),
                PrayerTime(name: .isha, time: timeToday(19, 55)),
            ]
        }

        let adjustment = settings.hijriAdjustment
        let dayNumber = hijri.ramadanDayNumber(for: today, adjustment: adjustment) ?? 1
        let hijriYear = hijri.currentRamadanHijriYear(from: today, adjustment: adjustment)
        let totalDays = hijri.ramadanLength(hijriYear: hijriYear)

        self.fastingDay = FastingDay(
            dayNumber: dayNumber,
            totalDays: totalDays,
            hijriDate: hijri.hijriDateString(from: today, adjustment: adjustment),
            gregorianDate: today,
            sehriTime: sehri,
            iftarTime: iftar,
            completed: false
        )

        self.prayerTimes = prayers
        self.verse = QuranVerse.verseOfTheDay()
        self.deed = DeedOfTheDay.deedOfTheDay()

        startTimer()
    }

    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.now = date
            }
    }

    func refresh() {
        countdown.recalculate()
        if let times = countdown.currentPrayerTimes {
            prayerTimes = times.allPrayers
            let settings = UserSettings.shared
            let adjustment = settings.hijriAdjustment
            let today = Date()
            let dayNumber = hijri.ramadanDayNumber(for: today, adjustment: adjustment) ?? 1
            let hijriYear = hijri.currentRamadanHijriYear(from: today, adjustment: adjustment)
            let totalDays = hijri.ramadanLength(hijriYear: hijriYear)

            fastingDay = FastingDay(
                dayNumber: dayNumber,
                totalDays: totalDays,
                hijriDate: hijri.hijriDateString(from: today, adjustment: adjustment),
                gregorianDate: today,
                sehriTime: times.imsak,
                iftarTime: times.iftar,
                completed: false
            )
        }
        now = Date()
    }
}
