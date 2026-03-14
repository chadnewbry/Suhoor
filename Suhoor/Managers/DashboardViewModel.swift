import SwiftUI
import Combine
import CoreLocation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var now = Date()
    @Published var prayerTimes: [PrayerTime] = []
    @Published var fastingDay: DashboardDay
    @Published var verse: QuranVerse
    @Published var deed: DeedOfTheDay
    @Published var fastsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    @Published var quranJuz: Int = 1
    @Published var deedsToday: Int = 0
    @Published var showAllPrayers: Bool = false
    @Published var isRamadan: Bool = true
    @Published var daysUntilRamadan: Int = 0

    private var timer: AnyCancellable?
    private var hasTriggeredIftarHaptic = false
    private let countdown = CountdownEngine.shared
    private let hijri = HijriCalendarService.shared

    // MARK: - Computed

    var nextPrayer: PrayerTime? {
        prayerTimes.first { $0.time > now }
    }

    var locationName: String {
        UserSettings.shared.selectedLocation?.name ?? "Unknown Location"
    }

    /// Re-detect location from device and save to UserSettings.
    func updateLocation() {
        let service = LocationService.shared
        if service.authorizationState == .authorized {
            service.detectLocation()
        } else {
            service.requestPermission()
        }
    }

    /// Called when LocationService finishes detecting. Saves and refreshes.
    func applyDetectedLocation() {
        guard let data = LocationService.shared.detectedLocationData else { return }
        UserSettings.shared.selectedLocation = data
        refresh()
    }

    var sehriTimeFormatted: String {
        formatTime(fastingDay.sehriTime)
    }

    var iftarTimeFormatted: String {
        formatTime(fastingDay.iftarTime)
    }

    /// True when current time is after iftar (night mode — cooler tones).
    var isNightMode: Bool {
        now >= fastingDay.iftarTime || now < fastingDay.sehriTime
    }

    var countdownLabel: String {
        if !isRamadan { return "Ramadan starts in" }
        return countdown.nextEvent?.label ?? fastingDay.timeToNextEvent(from: now).label
    }

    var countdownRemaining: TimeInterval {
        if !isRamadan {
            return Double(daysUntilRamadan) * 86400
        }
        return countdown.timeRemaining > 0 ? countdown.timeRemaining : fastingDay.timeToNextEvent(from: now).remaining
    }

    var countdownFormatted: (hours: String, minutes: String, seconds: String) {
        if !isRamadan {
            let days = daysUntilRamadan
            let d = days / 1 // just show days:00:00
            return (String(format: "%d", d), "days", "")
        }
        let cd = countdown.formattedCountdown
        if countdown.timeRemaining > 0 { return cd }
        let total = Int(max(countdownRemaining, 0))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return (String(format: "%02d", h), String(format: "%02d", m), String(format: "%02d", s))
    }

    var fastingProgress: Double {
        if !isRamadan { return 0 }
        return fastingDay.fastingProgress(at: now)
    }

    // MARK: - Init

    init() {
        let today = Date()
        let cal = Calendar.current
        let settings = UserSettings.shared
        let adjustment = settings.hijriAdjustment

        // Check if currently Ramadan
        let inRamadan = hijri.isRamadan(date: today, adjustment: adjustment)

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
            countdown.recalculate()
        } else {
            func timeToday(_ hour: Int, _ minute: Int) -> Date {
                cal.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
            }
            sehri = timeToday(5, 15)
            iftar = timeToday(18, 32)
            prayers = [
                PrayerTime(prayer: .fajr, date: today, time: timeToday(5, 15)),
                PrayerTime(prayer: .sunrise, date: today, time: timeToday(6, 38)),
                PrayerTime(prayer: .dhuhr, date: today, time: timeToday(12, 15)),
                PrayerTime(prayer: .asr, date: today, time: timeToday(15, 42)),
                PrayerTime(prayer: .maghrib, date: today, time: timeToday(18, 32)),
                PrayerTime(prayer: .isha, date: today, time: timeToday(19, 55)),
            ]
        }

        let dayNumber = hijri.ramadanDayNumber(for: today, adjustment: adjustment) ?? 1
        let hijriYear = hijri.currentRamadanHijriYear(from: today, adjustment: adjustment)
        let totalDays = hijri.ramadanLength(hijriYear: hijriYear)

        self.isRamadan = inRamadan
        self.daysUntilRamadan = inRamadan ? 0 : hijri.daysUntilNextRamadan(from: today, adjustment: adjustment)

        self.fastingDay = DashboardDay(
            dayNumber: dayNumber,
            totalDays: totalDays,
            hijriDate: hijri.hijriDateString(from: today, adjustment: adjustment),
            gregorianDate: today,
            sehriTime: sehri,
            iftarTime: iftar,
            completed: false
        )

        self.prayerTimes = prayers
        self.verse = QuranVerse.verseOfTheDay(ramadanDay: inRamadan ? dayNumber : nil)
        self.deed = DeedOfTheDay.deedOfTheDay()

        // Load streak from FastingStore
        let store = FastingStore()
        self.currentStreak = Self.calculateStreak(from: store.days)
        self.fastsCompleted = store.days.filter { $0.status == .fasted }.count

        startTimer()
    }

    // MARK: - Timer

    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.now = date
                self?.checkIftarHaptic()
            }
    }

    func refresh() {
        countdown.recalculate()
        let settings = UserSettings.shared
        let adjustment = settings.hijriAdjustment
        let today = Date()
        let inRamadan = hijri.isRamadan(date: today, adjustment: adjustment)
        isRamadan = inRamadan
        daysUntilRamadan = inRamadan ? 0 : hijri.daysUntilNextRamadan(from: today, adjustment: adjustment)

        if let times = countdown.currentPrayerTimes {
            prayerTimes = times.allPrayers
            let dayNumber = hijri.ramadanDayNumber(for: today, adjustment: adjustment) ?? 1
            let hijriYear = hijri.currentRamadanHijriYear(from: today, adjustment: adjustment)
            let totalDays = hijri.ramadanLength(hijriYear: hijriYear)

            fastingDay = DashboardDay(
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

    // MARK: - Haptic

    private func checkIftarHaptic() {
        guard isRamadan, !hasTriggeredIftarHaptic else { return }
        if now >= fastingDay.iftarTime {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            hasTriggeredIftarHaptic = true
        }
    }

    // MARK: - Streak

    private static func calculateStreak(from days: [FastingDay]) -> Int {
        var streak = 0
        for day in days.sorted(by: { $0.id > $1.id }) {
            if day.status == .fasted { streak += 1 }
            else if day.status != .future { break }
        }
        return streak
    }

    // MARK: - Helpers

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}
