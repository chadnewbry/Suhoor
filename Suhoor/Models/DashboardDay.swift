import Foundation

/// Lightweight value type for the dashboard's current-day display.
struct DashboardDay {
    let dayNumber: Int
    let totalDays: Int
    let hijriDate: String
    let gregorianDate: Date
    let sehriTime: Date
    let iftarTime: Date
    let completed: Bool

    var monthProgress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(dayNumber) / Double(totalDays)
    }

    var ashra: HijriCalendarService.Ashra {
        HijriCalendarService.shared.ashra(for: dayNumber)
    }

    func isFasting(at now: Date) -> Bool {
        now >= sehriTime && now < iftarTime
    }

    func fastingProgress(at now: Date) -> Double {
        let total = iftarTime.timeIntervalSince(sehriTime)
        guard total > 0 else { return 0 }
        let elapsed = now.timeIntervalSince(sehriTime)
        return min(max(elapsed / total, 0), 1)
    }

    func timeToNextEvent(from now: Date) -> (label: String, remaining: TimeInterval) {
        if now < sehriTime {
            return ("Until Sehri", sehriTime.timeIntervalSince(now))
        } else if now < iftarTime {
            return ("Until Iftar", iftarTime.timeIntervalSince(now))
        } else {
            let nextSehri = sehriTime.addingTimeInterval(86400)
            return ("Until Sehri", nextSehri.timeIntervalSince(now))
        }
    }
}
