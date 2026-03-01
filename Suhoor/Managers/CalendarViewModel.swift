import Foundation
import CoreLocation

// MARK: - Laylat al-Qadr Deed

struct QadrDeed: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    var completed: Bool = false
}

// MARK: - Eid Checklist Item

struct EidChecklistItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    var completed: Bool = false
}

// MARK: - Imsakiya Row (computed from existing DailyPrayerTimes)

struct ImsakiyaRow: Identifiable {
    let id: Int // ramadan day number
    let ramadanDay: Int
    let hijriLabel: String
    let gregorianDate: Date
    let prayerTimes: DailyPrayerTimes
    let isLastTenNights: Bool
    let isOddLastNight: Bool

    var gregorianDateString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: gregorianDate)
    }

    var dayOfWeekShort: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: gregorianDate)
    }
}

// MARK: - Calendar View Model

@MainActor
@Observable
final class CalendarViewModel {
    var rows: [ImsakiyaRow] = []
    var currentRamadanDay: Int? = nil
    var daysUntilEid: Int? = nil
    var qadrDeeds: [String: [QadrDeed]] = [:]
    var eidChecklist: [EidChecklistItem] = []

    private let hijriService = HijriCalendarService.shared
    private let calculator = PrayerTimesCalculator.shared
    private let settings = UserSettings.shared

    private let defaultDeeds: [QadrDeed] = [
        QadrDeed(id: "tahajjud", name: "Tahajjud Prayer", emoji: "🕌"),
        QadrDeed(id: "quran", name: "Quran Recitation", emoji: "📖"),
        QadrDeed(id: "dua", name: "Extra Du'a", emoji: "🤲"),
        QadrDeed(id: "dhikr", name: "Dhikr & Istighfar", emoji: "📿"),
        QadrDeed(id: "sadaqah", name: "Charity / Sadaqah", emoji: "💝"),
        QadrDeed(id: "itikaf", name: "I'tikaf (time in masjid)", emoji: "🏠"),
    ]

    init() {
        loadQadrDeeds()
        loadEidChecklist()
        recalculate()
    }

    func recalculate() {
        let location = settings.selectedLocation
        let coord = CLLocationCoordinate2D(
            latitude: location?.latitude ?? 40.7128,
            longitude: location?.longitude ?? -74.0060
        )
        let tz = location?.timeZone ?? .current
        let method = settings.calculationMethod
        let madhhab = settings.madhhab
        let adjustment = settings.hijriAdjustment
        let hijriYear = hijriService.currentRamadanHijriYear(adjustment: adjustment)
        let totalDays = hijriService.ramadanLength(hijriYear: hijriYear)

        guard let range = hijriService.ramadanDateRange(hijriYear: hijriYear) else { return }

        var result: [ImsakiyaRow] = []
        let cal = Calendar.current

        for dayOffset in 0..<totalDays {
            guard let date = cal.date(byAdding: .day, value: dayOffset, to: range.start) else { continue }
            let dayNum = dayOffset + 1
            let times = calculator.calculate(
                for: date, coordinate: coord, timeZone: tz,
                method: method, madhhab: madhhab
            )
            let hijriLabel = "\(dayNum) Ramadan \(hijriYear)"

            result.append(ImsakiyaRow(
                id: dayNum,
                ramadanDay: dayNum,
                hijriLabel: hijriLabel,
                gregorianDate: date,
                prayerTimes: times,
                isLastTenNights: hijriService.isLastTenNights(ramadanDay: dayNum, totalDays: totalDays),
                isOddLastNight: hijriService.isLaylatAlQadrCandidate(ramadanDay: dayNum, totalDays: totalDays)
            ))
        }

        rows = result

        // Current day
        currentRamadanDay = hijriService.ramadanDayNumber(for: .now, adjustment: adjustment)

        // Eid countdown
        if let eidDate = hijriService.eidAlFitrDate(hijriYear: hijriYear) {
            let today = cal.startOfDay(for: .now)
            let eid = cal.startOfDay(for: eidDate)
            if let diff = cal.dateComponents([.day], from: today, to: eid).day, diff >= 0 {
                daysUntilEid = diff
            }
        }
    }

    // MARK: - Laylat al-Qadr Persistence

    private func loadQadrDeeds() {
        if let data = UserDefaults.standard.data(forKey: "qadr_deeds_v2"),
           let decoded = try? JSONDecoder().decode([String: [QadrDeed]].self, from: data) {
            qadrDeeds = decoded
        } else {
            for night in [21, 23, 25, 27, 29] {
                qadrDeeds["night_\(night)"] = defaultDeeds
            }
        }
    }

    func toggleQadrDeed(night: Int, deedId: String) {
        guard var deeds = qadrDeeds["night_\(night)"] else { return }
        if let idx = deeds.firstIndex(where: { $0.id == deedId }) {
            deeds[idx].completed.toggle()
            qadrDeeds["night_\(night)"] = deeds
            if let data = try? JSONEncoder().encode(qadrDeeds) {
                UserDefaults.standard.set(data, forKey: "qadr_deeds_v2")
            }
        }
    }

    // MARK: - Eid Checklist

    private func loadEidChecklist() {
        if let data = UserDefaults.standard.data(forKey: "eid_checklist_v2"),
           let decoded = try? JSONDecoder().decode([EidChecklistItem].self, from: data) {
            eidChecklist = decoded
        } else {
            eidChecklist = [
                EidChecklistItem(id: "zakat", name: "Pay Zakat al-Fitr", emoji: "💰"),
                EidChecklistItem(id: "outfit", name: "Prepare Eid outfit", emoji: "👔"),
                EidChecklistItem(id: "greetings", name: "Send Eid greetings", emoji: "💌"),
                EidChecklistItem(id: "food", name: "Prepare Eid food/sweets", emoji: "🍰"),
                EidChecklistItem(id: "gifts", name: "Get Eid gifts", emoji: "🎁"),
                EidChecklistItem(id: "prayer", name: "Plan for Eid prayer", emoji: "🕌"),
            ]
        }
    }

    func toggleEidItem(_ itemId: String) {
        if let idx = eidChecklist.firstIndex(where: { $0.id == itemId }) {
            eidChecklist[idx].completed.toggle()
            if let data = try? JSONEncoder().encode(eidChecklist) {
                UserDefaults.standard.set(data, forKey: "eid_checklist_v2")
            }
        }
    }
}
