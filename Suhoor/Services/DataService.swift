import Foundation
import SwiftData

/// Convenience queries and data operations for Suhoor models.
struct DataService {

    // MARK: - Fasting Records

    static func fastingRecord(for date: Date, in context: ModelContext) -> FastingRecord? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let predicate = #Predicate<FastingRecord> { record in
            record.date >= start && record.date < end
        }

        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? context.fetch(descriptor).first
    }

    static func allFastingRecords(in context: ModelContext) -> [FastingRecord] {
        let descriptor = FetchDescriptor<FastingRecord>(
            sortBy: [SortDescriptor(\.date)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    static func completedFastCount(in context: ModelContext) -> Int {
        let statusRaw = FastingStatus.fasted.rawValue
        let predicate = #Predicate<FastingRecord> { $0.statusRaw == statusRaw }
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    // MARK: - Quran Progress

    static func quranProgress(for date: Date, in context: ModelContext) -> QuranProgress? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let predicate = #Predicate<QuranProgress> { progress in
            progress.date >= start && progress.date < end
        }

        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? context.fetch(descriptor).first
    }

    static func totalPagesRead(in context: ModelContext) -> Int {
        let all = (try? context.fetch(FetchDescriptor<QuranProgress>())) ?? []
        return all.reduce(0) { $0 + $1.pagesRead }
    }

    // MARK: - Makeup Fasts

    static func pendingMakeupFasts(in context: ModelContext) -> [MakeupFast] {
        let predicate = #Predicate<MakeupFast> { !$0.isCompleted }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.originalDate)])
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Hydration

    static func totalHydration(for date: Date, in context: ModelContext) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let predicate = #Predicate<HydrationEntry> { entry in
            entry.date >= start && entry.date < end
        }

        let entries = (try? context.fetch(FetchDescriptor(predicate: predicate))) ?? []
        return entries.reduce(0) { $0 + $1.amountMl }
    }

    // MARK: - Deeds

    static func deeds(for date: Date, in context: ModelContext) -> [DeedEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let predicate = #Predicate<DeedEntry> { entry in
            entry.date >= start && entry.date < end
        }

        return (try? context.fetch(FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.date)]))) ?? []
    }
}
