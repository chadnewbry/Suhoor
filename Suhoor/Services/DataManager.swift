import Foundation
import SwiftData

/// Singleton providing CRUD convenience methods, streak logic,
/// makeup-fast counting, and year-over-year comparison queries.
@MainActor
@Observable
final class DataManager {
    static let shared = DataManager()

    var modelContainer: ModelContainer = .suhoor
    var modelContext: ModelContext { modelContainer.mainContext }

    private init() {}

    // MARK: - Save

    func save() {
        try? modelContext.save()
    }

    // MARK: - Fasting Records (CRUD)

    func addFastingRecord(
        date: Date,
        dayNumber: Int,
        ramadanYear: Int,
        status: FastingStatus = .fasted,
        excuseReason: ExcuseReason? = nil,
        notes: String? = nil,
        fastStartTime: Date,
        fastEndTime: Date
    ) -> FastingRecord {
        let record = FastingRecord(
            date: date,
            dayNumber: dayNumber,
            ramadanYear: ramadanYear,
            status: status,
            excuseReason: excuseReason,
            notes: notes,
            fastStartTime: fastStartTime,
            fastEndTime: fastEndTime
        )
        modelContext.insert(record)

        // Auto-create makeup fast for missed/excused days
        if status == .missed || status == .excused {
            let reason = excuseReason?.rawValue ?? status.rawValue
            let makeup = MakeupFast(originalDate: date, reason: reason)
            makeup.originalFastingRecord = record
            modelContext.insert(makeup)
        }

        save()
        return record
    }

    func fastingRecord(for date: Date) -> FastingRecord? {
        DataService.fastingRecord(for: date, in: modelContext)
    }

    func allFastingRecords() -> [FastingRecord] {
        DataService.allFastingRecords(in: modelContext)
    }

    func fastingRecords(forRamadanYear year: Int) -> [FastingRecord] {
        let predicate = #Predicate<FastingRecord> { $0.ramadanYear == year }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.dayNumber)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteFastingRecord(_ record: FastingRecord) {
        modelContext.delete(record)
        save()
    }

    // MARK: - Quran Progress (CRUD)

    @discardableResult
    func addQuranProgress(
        date: Date,
        juzNumber: Int,
        pagesRead: Int = 0,
        isCompleted: Bool = false,
        ramadanYear: Int
    ) -> QuranProgress {
        let progress = QuranProgress(
            date: date,
            juzNumber: juzNumber,
            isCompleted: isCompleted,
            pagesRead: pagesRead,
            ramadanYear: ramadanYear
        )
        modelContext.insert(progress)
        save()
        return progress
    }

    func quranProgress(for date: Date) -> QuranProgress? {
        DataService.quranProgress(for: date, in: modelContext)
    }

    func quranProgress(forRamadanYear year: Int) -> [QuranProgress] {
        let predicate = #Predicate<QuranProgress> { $0.ramadanYear == year }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.date)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Deed Entries (CRUD)

    @discardableResult
    func addDeedEntry(
        date: Date,
        deedType: DeedType,
        customLabel: String? = nil,
        ramadanYear: Int
    ) -> DeedEntry {
        let entry = DeedEntry(date: date, deedType: deedType, customLabel: customLabel, ramadanYear: ramadanYear)
        modelContext.insert(entry)
        save()
        return entry
    }

    func deeds(for date: Date) -> [DeedEntry] {
        DataService.deeds(for: date, in: modelContext)
    }

    // MARK: - Hydration (CRUD)

    @discardableResult
    func addHydrationEntry(
        date: Date,
        glassesCount: Int = 1,
        targetGlasses: Int = 8,
        amountMl: Int = 250
    ) -> HydrationEntry {
        let entry = HydrationEntry(
            date: date,
            amountMl: amountMl,
            glassesCount: glassesCount,
            targetGlasses: targetGlasses
        )
        modelContext.insert(entry)
        save()
        return entry
    }

    // MARK: - Badges (CRUD)

    @discardableResult
    func awardBadge(_ badgeType: BadgeType, ramadanYear: Int) -> Badge? {
        // Don't award duplicate badges
        let raw = badgeType.rawValue
        let predicate = #Predicate<Badge> { $0.badgeTypeRaw == raw && $0.ramadanYear == ramadanYear }
        let descriptor = FetchDescriptor(predicate: predicate)
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return existing.first }

        let badge = Badge(badgeType: badgeType, ramadanYear: ramadanYear)
        modelContext.insert(badge)
        save()
        return badge
    }

    func badges(forRamadanYear year: Int) -> [Badge] {
        let predicate = #Predicate<Badge> { $0.ramadanYear == year }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.earnedDate)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Streak Calculation

    /// Returns the current consecutive fasted-day streak for a given Ramadan year.
    func currentStreak(ramadanYear: Int) -> Int {
        let records = fastingRecords(forRamadanYear: ramadanYear)
        var streak = 0
        // Walk backwards from highest day number
        for record in records.reversed() {
            if record.status == .fasted {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    /// Returns the longest consecutive fasted-day streak for a given Ramadan year.
    func longestStreak(ramadanYear: Int) -> Int {
        let records = fastingRecords(forRamadanYear: ramadanYear)
        var longest = 0
        var current = 0
        for record in records {
            if record.status == .fasted {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }

    /// Checks streak milestones and awards badges if thresholds are met.
    func checkAndAwardStreakBadges(ramadanYear: Int) {
        let streak = longestStreak(ramadanYear: ramadanYear)
        for badgeType in [BadgeType.streak7, .streak15, .streak30] {
            if let threshold = badgeType.streakThreshold, streak >= threshold {
                awardBadge(badgeType, ramadanYear: ramadanYear)
            }
        }

        // Check ashra completion
        let records = fastingRecords(forRamadanYear: ramadanYear)
        let fastedDays = Set(records.filter { $0.status == .fasted }.map(\.dayNumber))

        if Set(1...10).isSubset(of: fastedDays) { awardBadge(.fullAshra1, ramadanYear: ramadanYear) }
        if Set(11...20).isSubset(of: fastedDays) { awardBadge(.fullAshra2, ramadanYear: ramadanYear) }
        if Set(21...30).isSubset(of: fastedDays) { awardBadge(.fullAshra3, ramadanYear: ramadanYear) }
        if Set(1...30).isSubset(of: fastedDays) { awardBadge(.allFasted, ramadanYear: ramadanYear) }
    }

    /// Check if Quran khatam (all 30 juz completed) and award badge.
    func checkAndAwardKhatamBadge(ramadanYear: Int) {
        let progress = quranProgress(forRamadanYear: ramadanYear)
        let completedJuz = Set(progress.filter(\.isCompleted).map(\.juzNumber))
        if completedJuz.count >= 30 {
            awardBadge(.khatam, ramadanYear: ramadanYear)
        }
    }

    // MARK: - Makeup Fast Counter

    func pendingMakeupFasts() -> [MakeupFast] {
        DataService.pendingMakeupFasts(in: modelContext)
    }

    var pendingMakeupFastCount: Int {
        pendingMakeupFasts().count
    }

    func completeMakeupFast(_ makeupFast: MakeupFast) {
        makeupFast.isCompleted = true
        makeupFast.completedDate = .now
        save()
    }

    // MARK: - Year-over-Year Comparison

    struct RamadanSummary {
        let ramadanYear: Int
        let totalFasted: Int
        let totalMissed: Int
        let totalExcused: Int
        let longestStreak: Int
        let totalPagesRead: Int
        let totalDeedsCompleted: Int
        let badges: [Badge]
    }

    func summary(forRamadanYear year: Int) -> RamadanSummary {
        let records = fastingRecords(forRamadanYear: year)
        let fasted = records.filter { $0.status == .fasted }.count
        let missed = records.filter { $0.status == .missed }.count
        let excused = records.filter { $0.status == .excused }.count

        let quran = quranProgress(forRamadanYear: year)
        let pages = quran.reduce(0) { $0 + $1.pagesRead }

        let yearPredicate = year
        let deedPredicate = #Predicate<DeedEntry> { $0.ramadanYear == yearPredicate && $0.isCompleted }
        let deedsCount = (try? modelContext.fetchCount(FetchDescriptor(predicate: deedPredicate))) ?? 0

        return RamadanSummary(
            ramadanYear: year,
            totalFasted: fasted,
            totalMissed: missed,
            totalExcused: excused,
            longestStreak: longestStreak(ramadanYear: year),
            totalPagesRead: pages,
            totalDeedsCompleted: deedsCount,
            badges: badges(forRamadanYear: year)
        )
    }

    /// Compare two Ramadan years side-by-side.
    func compareYears(_ year1: Int, _ year2: Int) -> (current: RamadanSummary, previous: RamadanSummary) {
        (summary(forRamadanYear: year1), summary(forRamadanYear: year2))
    }

    /// All distinct Ramadan years that have data.
    func availableRamadanYears() -> [Int] {
        let records = allFastingRecords()
        return Array(Set(records.map(\.ramadanYear))).sorted()
    }
}
