#if DEBUG
import Foundation
import SwiftData

/// Populates the SwiftData store with curated sample content for App Store screenshot capture.
/// Activated by passing `--screenshot-mode` as a launch argument.
@MainActor
enum ScreenshotSampleData {
    static var isScreenshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("--screenshot-mode")
    }

    /// Clears existing data and inserts polished sample content for all key screens.
    static func populate(context: ModelContext) {
        // Clear existing data
        try? context.delete(model: FastingRecord.self)
        try? context.delete(model: QuranProgress.self)
        try? context.delete(model: DeedEntry.self)
        try? context.delete(model: HydrationEntry.self)
        try? context.delete(model: MakeupFast.self)
        try? context.delete(model: Badge.self)

        let calendar = Calendar.current
        let ramadanYear = 1446

        // --- Fasting Records: 18 days of a strong Ramadan ---
        for day in 1...18 {
            let date = calendar.date(byAdding: .day, value: day - 18, to: .now)!
            let startOfDay = calendar.startOfDay(for: date)
            let suhoorTime = calendar.date(bySettingHour: 4, minute: 30, second: 0, of: startOfDay)!
            let iftarTime = calendar.date(bySettingHour: 18, minute: 45, second: 0, of: startOfDay)!

            let status: FastingStatus = (day == 12) ? .excused : .fasted
            let excuse: ExcuseReason? = (day == 12) ? .illness : nil

            let record = FastingRecord(
                date: startOfDay,
                dayNumber: day,
                ramadanYear: ramadanYear,
                status: status,
                excuseReason: excuse,
                fastStartTime: suhoorTime,
                fastEndTime: iftarTime
            )
            context.insert(record)

            // Hydration entries for iftar time
            if status == .fasted {
                let hydration = HydrationEntry(
                    date: startOfDay,
                    amountMl: Int.random(in: 1500...2500),
                    glassesCount: Int.random(in: 6...10),
                    targetGlasses: 8,
                    timestamp: iftarTime
                )
                hydration.fastingRecord = record
                context.insert(hydration)
            }

            // Daily deeds
            let deedTypes: [DeedType] = [.charity, .extraPrayer, .quranReading, .dhikr, .dua]
            for deedType in deedTypes {
                let deed = DeedEntry(
                    date: startOfDay,
                    deedType: deedType,
                    ramadanYear: ramadanYear
                )
                deed.isCompleted = day <= 16 || deedType == .quranReading || deedType == .dhikr
                deed.fastingRecord = record
                context.insert(deed)
            }
        }

        // --- Quran Progress: 14 juz completed ---
        for juz in 1...14 {
            let date = calendar.date(byAdding: .day, value: juz - 18, to: .now)!
            let progress = QuranProgress(
                date: calendar.startOfDay(for: date),
                juzNumber: juz,
                isCompleted: true,
                pagesRead: 20,
                readingDurationMinutes: Int.random(in: 25...45),
                ramadanYear: ramadanYear
            )
            context.insert(progress)
        }

        // Juz 15 in progress
        let todayProgress = QuranProgress(
            date: calendar.startOfDay(for: .now),
            juzNumber: 15,
            isCompleted: false,
            pagesRead: 8,
            readingDurationMinutes: 12,
            ramadanYear: ramadanYear
        )
        context.insert(todayProgress)

        // --- Badges ---
        let earnedBadges: [BadgeType] = [.streak7, .streak15, .fullAshra1]
        for badgeType in earnedBadges {
            let badge = Badge(badgeType: badgeType, ramadanYear: ramadanYear)
            context.insert(badge)
        }

        // --- Makeup Fast for the excused day ---
        let excusedDate = calendar.date(byAdding: .day, value: 12 - 18, to: .now)!
        let makeup = MakeupFast(
            originalDate: calendar.startOfDay(for: excusedDate),
            reason: ExcuseReason.illness.rawValue
        )
        context.insert(makeup)

        try? context.save()
    }
}
#endif
