import SwiftUI
import Combine

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
    
    var nextPrayer: PrayerTime? {
        prayerTimes.first { $0.time > now }
    }
    
    var countdownLabel: String {
        fastingDay.timeToNextEvent(from: now).label
    }
    
    var countdownRemaining: TimeInterval {
        fastingDay.timeToNextEvent(from: now).remaining
    }
    
    var countdownFormatted: (hours: String, minutes: String, seconds: String) {
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
        
        // Generate sample prayer times for today
        func timeToday(_ hour: Int, _ minute: Int) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
        }
        
        let sehri = timeToday(5, 15)
        let iftar = timeToday(18, 32)
        
        self.fastingDay = FastingDay(
            dayNumber: 5,
            totalDays: 30,
            hijriDate: "5 Ramadan 1447",
            gregorianDate: today,
            sehriTime: sehri,
            iftarTime: iftar,
            completed: false
        )
        
        self.prayerTimes = [
            PrayerTime(name: .fajr, time: timeToday(5, 15)),
            PrayerTime(name: .sunrise, time: timeToday(6, 38)),
            PrayerTime(name: .dhuhr, time: timeToday(12, 15)),
            PrayerTime(name: .asr, time: timeToday(15, 42)),
            PrayerTime(name: .maghrib, time: timeToday(18, 32)),
            PrayerTime(name: .isha, time: timeToday(19, 55)),
        ]
        
        self.verse = QuranVerse.verseOfTheDay()
        self.deed = DeedOfTheDay.deedOfTheDay()
        self.fastsCompleted = 4
        self.currentStreak = 4
        self.quranJuz = 3
        self.deedsToday = 2
        
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
        // In production, recalculate prayer times from engine
        now = Date()
    }
}
