import Foundation

/// Hijri (Islamic) calendar utilities for Ramadan tracking.
struct HijriCalendarService {

    static let shared = HijriCalendarService()

    private let islamicCalendar: Calendar = {
        var cal = Calendar(identifier: .islamicUmmAlQura)
        cal.locale = Locale(identifier: "en_US")
        return cal
    }()

    // MARK: - Gregorian ↔ Hijri

    /// Convert a Gregorian date to a Hijri date string.
    func hijriDateString(from date: Date, adjustment: Int = 0) -> String {
        let adjusted = Calendar.current.date(byAdding: .day, value: adjustment, to: date) ?? date
        let formatter = DateFormatter()
        formatter.calendar = islamicCalendar
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: adjusted)
    }

    /// Hijri components for a Gregorian date.
    func hijriComponents(from date: Date, adjustment: Int = 0) -> DateComponents {
        let adjusted = Calendar.current.date(byAdding: .day, value: adjustment, to: date) ?? date
        return islamicCalendar.dateComponents([.year, .month, .day], from: adjusted)
    }

    // MARK: - Ramadan

    /// Returns true if the given date falls in Ramadan.
    func isRamadan(date: Date, adjustment: Int = 0) -> Bool {
        let comps = hijriComponents(from: date, adjustment: adjustment)
        return comps.month == 9 // Ramadan is month 9 in Islamic calendar
    }

    /// Current Ramadan day number (1–30), or nil if not Ramadan.
    func ramadanDayNumber(for date: Date, adjustment: Int = 0) -> Int? {
        let comps = hijriComponents(from: date, adjustment: adjustment)
        guard comps.month == 9 else { return nil }
        return comps.day
    }

    /// The Hijri year for the current or upcoming Ramadan.
    func currentRamadanHijriYear(from date: Date = .now, adjustment: Int = 0) -> Int {
        let comps = hijriComponents(from: date, adjustment: adjustment)
        // If we're past Ramadan (month > 9), next Ramadan is next year
        if let month = comps.month, let year = comps.year {
            return month > 9 ? year + 1 : year
        }
        return comps.year ?? 1446
    }

    /// Gregorian date range for Ramadan of a given Hijri year.
    func ramadanDateRange(hijriYear: Int) -> (start: Date, end: Date)? {
        var startComps = DateComponents()
        startComps.year = hijriYear
        startComps.month = 9
        startComps.day = 1

        var endComps = DateComponents()
        endComps.year = hijriYear
        endComps.month = 9
        endComps.day = 30

        guard let start = islamicCalendar.date(from: startComps),
              let end = islamicCalendar.date(from: endComps) else { return nil }
        return (start, end)
    }

    /// Number of days in the current Ramadan.
    func ramadanLength(hijriYear: Int) -> Int {
        var comps = DateComponents()
        comps.year = hijriYear
        comps.month = 9
        comps.day = 1
        guard let ramadanStart = islamicCalendar.date(from: comps),
              let range = islamicCalendar.range(of: .day, in: .month, for: ramadanStart) else { return 30 }
        return range.count
    }

    // MARK: - Laylat al-Qadr

    /// Returns true if this Ramadan night is a potential Laylat al-Qadr night.
    /// Traditional view: odd nights of the last 10 (21, 23, 25, 27, 29).
    func isLaylatAlQadrCandidate(ramadanDay: Int, totalDays: Int) -> Bool {
        let lastTenStart = totalDays - 9
        guard ramadanDay >= lastTenStart else { return false }
        return ramadanDay % 2 == 1 // Odd nights
    }

    /// Returns true if this day is in the last 10 nights of Ramadan.
    func isLastTenNights(ramadanDay: Int, totalDays: Int) -> Bool {
        ramadanDay >= (totalDays - 9)
    }

    // MARK: - Eid al-Fitr

    /// Approximate Gregorian date of Eid al-Fitr (1 Shawwal) for a given Hijri year.
    func eidAlFitrDate(hijriYear: Int) -> Date? {
        var comps = DateComponents()
        comps.year = hijriYear
        comps.month = 10 // Shawwal
        comps.day = 1
        return islamicCalendar.date(from: comps)
    }
}
