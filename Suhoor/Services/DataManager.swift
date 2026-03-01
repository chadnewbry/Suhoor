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

// MARK: - Deed Master Badge

extension DataManager {
    /// Check if the user completed all default deed types every day for 7 consecutive days.
    func checkAndAwardDeedMasterBadge(ramadanYear: Int) {
        let records = fastingRecords(forRamadanYear: ramadanYear)
        let defaultDeedTypes: Set<String> = [
            DeedType.charity.rawValue,
            DeedType.extraPrayer.rawValue,
            DeedType.quranReading.rawValue,
            DeedType.dhikr.rawValue,
            DeedType.dua.rawValue,
        ]

        // For each day, check if all default deeds are completed
        var consecutiveDays = 0
        for record in records.sorted(by: { $0.dayNumber < $1.dayNumber }) {
            let dayDeeds = record.deedEntries.filter { $0.isCompleted }
            let completedTypes = Set(dayDeeds.map(\.deedTypeRaw))
            if defaultDeedTypes.isSubset(of: completedTypes) {
                consecutiveDays += 1
                if consecutiveDays >= 7 {
                    awardBadge(.deedMaster, ramadanYear: ramadanYear)
                    return
                }
            } else {
                consecutiveDays = 0
            }
        }
    }

    /// Number of completed juz for a Ramadan year.
    func completedJuzCount(ramadanYear: Int) -> Int {
        let progress = quranProgress(forRamadanYear: ramadanYear)
        return Set(progress.filter(\.isCompleted).map(\.juzNumber)).count
    }

    /// Total deeds completed for a Ramadan year.
    func totalDeedsCompleted(ramadanYear: Int) -> Int {
        let yearPredicate = ramadanYear
        let predicate = #Predicate<DeedEntry> { $0.ramadanYear == yearPredicate && $0.isCompleted }
        return (try? modelContext.fetchCount(FetchDescriptor(predicate: predicate))) ?? 0
    }

    /// All deed entries for a specific date.
    func deedEntries(for date: Date, ramadanYear: Int) -> [DeedEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let year = ramadanYear

        let predicate = #Predicate<DeedEntry> { entry in
            entry.date >= start && entry.date < end && entry.ramadanYear == year
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.date)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Toggle deed completion.
    func toggleDeed(_ deed: DeedEntry) {
        deed.isCompleted.toggle()
        save()
    }

    /// Delete a deed entry.
    func deleteDeed(_ deed: DeedEntry) {
        modelContext.delete(deed)
        save()
    }

    /// Ensure default deeds exist for today.
    func ensureDefaultDeeds(for date: Date, ramadanYear: Int) {
        let existing = deedEntries(for: date, ramadanYear: ramadanYear)
        let existingTypes = Set(existing.map(\.deedTypeRaw))
        let defaults: [DeedType] = [.charity, .extraPrayer, .quranReading, .dhikr, .dua]

        for deedType in defaults {
            if !existingTypes.contains(deedType.rawValue) {
                addDeedEntry(date: date, deedType: deedType, ramadanYear: ramadanYear)
            }
        }
    }

    /// Badge progress (0.0–1.0) for a badge type.
    func badgeProgress(_ badgeType: BadgeType, ramadanYear: Int) -> Double {
        switch badgeType {
        case .streak7:
            return min(Double(longestStreak(ramadanYear: ramadanYear)) / 7.0, 1.0)
        case .streak15:
            return min(Double(longestStreak(ramadanYear: ramadanYear)) / 15.0, 1.0)
        case .streak30:
            return min(Double(longestStreak(ramadanYear: ramadanYear)) / 30.0, 1.0)
        case .fullAshra1:
            let records = fastingRecords(forRamadanYear: ramadanYear)
            let fasted = Set(records.filter { $0.status == .fasted && $0.dayNumber >= 1 && $0.dayNumber <= 10 }.map(\.dayNumber))
            return Double(fasted.count) / 10.0
        case .fullAshra2:
            let records = fastingRecords(forRamadanYear: ramadanYear)
            let fasted = Set(records.filter { $0.status == .fasted && $0.dayNumber >= 11 && $0.dayNumber <= 20 }.map(\.dayNumber))
            return Double(fasted.count) / 10.0
        case .fullAshra3:
            let records = fastingRecords(forRamadanYear: ramadanYear)
            let fasted = Set(records.filter { $0.status == .fasted && $0.dayNumber >= 21 && $0.dayNumber <= 30 }.map(\.dayNumber))
            return Double(fasted.count) / 10.0
        case .khatam:
            return Double(completedJuzCount(ramadanYear: ramadanYear)) / 30.0
        case .allFasted:
            let records = fastingRecords(forRamadanYear: ramadanYear)
            let fasted = records.filter { $0.status == .fasted }.count
            return Double(fasted) / 30.0
        case .deedMaster:
            // Simplified: show longest consecutive "all deeds" streak / 7
            let records = fastingRecords(forRamadanYear: ramadanYear)
            let defaultDeedTypes: Set<String> = [
                DeedType.charity.rawValue, DeedType.extraPrayer.rawValue,
                DeedType.quranReading.rawValue, DeedType.dhikr.rawValue,
                DeedType.dua.rawValue,
            ]
            var best = 0
            var current = 0
            for record in records.sorted(by: { $0.dayNumber < $1.dayNumber }) {
                let completedTypes = Set(record.deedEntries.filter(\.isCompleted).map(\.deedTypeRaw))
                if defaultDeedTypes.isSubset(of: completedTypes) {
                    current += 1
                    best = max(best, current)
                } else {
                    current = 0
                }
            }
            return min(Double(best) / 7.0, 1.0)
        }
    }
}
