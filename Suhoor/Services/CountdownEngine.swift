import Foundation
import Combine
import CoreLocation

/// Tracks upcoming prayer/sehri/iftar events and provides real-time countdowns.
@MainActor
@Observable
final class CountdownEngine {

    static let shared = CountdownEngine()

    // MARK: - Published State

    private(set) var currentPrayerTimes: DailyPrayerTimes?
    private(set) var nextEvent: CountdownEvent?
    private(set) var timeRemaining: TimeInterval = 0

    var formattedCountdown: (hours: String, minutes: String, seconds: String) {
        let total = max(Int(timeRemaining), 0)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return (String(format: "%02d", h), String(format: "%02d", m), String(format: "%02d", s))
    }

    // MARK: - Private

    private var timer: AnyCancellable?
    private var todayPrayerTimes: DailyPrayerTimes?
    private var tomorrowPrayerTimes: DailyPrayerTimes?

    private init() {
        startTimer()
    }

    // MARK: - Configuration

    /// Recalculate prayer times for today and tomorrow using current settings.
    func recalculate() {
        let settings = UserSettings.shared
        guard let location = settings.selectedLocation else { return }

        let coord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let tz = location.timeZone ?? .current
        let method = settings.calculationMethod
        let madhhab = settings.madhhab
        let calc = PrayerTimesCalculator.shared

        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        todayPrayerTimes = calc.calculate(for: today, coordinate: coord, timeZone: tz, method: method, madhhab: madhhab)
        tomorrowPrayerTimes = calc.calculate(for: tomorrow, coordinate: coord, timeZone: tz, method: method, madhhab: madhhab)
        currentPrayerTimes = todayPrayerTimes

        tick()
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        let now = Date()
        guard let today = todayPrayerTimes else { return }

        // Build ordered events for today
        let todayEvents = orderedEvents(from: today)

        // Find next upcoming event
        if let next = todayEvents.first(where: { $0.time > now }) {
            nextEvent = next
            timeRemaining = next.time.timeIntervalSince(now)
        } else if let tomorrow = tomorrowPrayerTimes {
            // All today's events passed — look at tomorrow's imsak/fajr
            let tomorrowEvents = orderedEvents(from: tomorrow)
            if let next = tomorrowEvents.first {
                nextEvent = next
                timeRemaining = next.time.timeIntervalSince(now)
            }
        }
    }

    private func orderedEvents(from times: DailyPrayerTimes) -> [CountdownEvent] {
        [
            CountdownEvent(label: "Imsak (Sehri)", time: times.imsak, kind: .imsak),
            CountdownEvent(label: "Fajr", time: times.fajr, kind: .fajr),
            CountdownEvent(label: "Sunrise", time: times.sunrise, kind: .sunrise),
            CountdownEvent(label: "Dhuhr", time: times.dhuhr, kind: .dhuhr),
            CountdownEvent(label: "Asr", time: times.asr, kind: .asr),
            CountdownEvent(label: "Iftar", time: times.iftar, kind: .iftar),
            CountdownEvent(label: "Maghrib", time: times.maghrib, kind: .maghrib),
            CountdownEvent(label: "Isha", time: times.isha, kind: .isha),
            CountdownEvent(label: "Taraweeh", time: times.taraweeh, kind: .taraweeh),
        ]
    }

    // MARK: - Live Activity Support

    /// Data snapshot for Live Activity / Widget updates.
    var liveActivityData: [String: Date] {
        guard let times = currentPrayerTimes else { return [:] }
        return [
            "imsak": times.imsak,
            "fajr": times.fajr,
            "sunrise": times.sunrise,
            "dhuhr": times.dhuhr,
            "asr": times.asr,
            "maghrib": times.maghrib,
            "isha": times.isha,
            "iftar": times.iftar,
            "taraweeh": times.taraweeh,
        ]
    }
}

// MARK: - Countdown Event

struct CountdownEvent: Identifiable {
    let id = UUID()
    let label: String
    let time: Date
    let kind: EventKind

    enum EventKind: String {
        case imsak, fajr, sunrise, dhuhr, asr, maghrib, isha, iftar, taraweeh
    }

    var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: time)
    }
}
