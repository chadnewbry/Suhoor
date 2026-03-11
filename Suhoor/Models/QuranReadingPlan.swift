import Foundation

// MARK: - Juz Info

struct JuzInfo: Codable, Identifiable {
    let juz: Int
    let startSurah: String
    let startAyah: Int
    let endSurah: String
    let endAyah: Int
    let totalPages: Int

    var id: Int { juz }
}

// MARK: - Daily Reading

struct DailyReading: Codable, Identifiable {
    let day: Int
    let juz: Int
    var pagesRead: Int
    let totalPages: Int

    var id: Int { day }
    var completionPercentage: Double {
        guard totalPages > 0 else { return 0 }
        return min(Double(pagesRead) / Double(totalPages), 1.0)
    }

    var isComplete: Bool { pagesRead >= totalPages }
}

// MARK: - Reading Progress

struct ReadingProgress: Codable {
    var dailyReadings: [DailyReading]
    let totalJuz: Int
    let totalPages: Int

    var completedJuz: Int {
        dailyReadings.filter(\.isComplete).count
    }

    var khatamPercentage: Double {
        guard totalPages > 0 else { return 0 }
        let read = dailyReadings.reduce(0) { $0 + $1.pagesRead }
        return min(Double(read) / Double(totalPages), 1.0)
    }

    var totalPagesRead: Int {
        dailyReadings.reduce(0) { $0 + $1.pagesRead }
    }

    var currentDay: Int {
        let islamic = Calendar(identifier: .islamicUmmAlQura)
        let comps = islamic.dateComponents([.month, .day], from: Date())
        guard comps.month == 9 else { return 1 }
        return comps.day ?? 1
    }

    var averagePagesPerDay: Double {
        guard currentDay > 0 else { return 0 }
        return Double(totalPagesRead) / Double(currentDay)
    }

    var estimatedCompletionDate: Date? {
        guard averagePagesPerDay > 0 else { return nil }
        let remaining = totalPages - totalPagesRead
        let daysNeeded = Int(ceil(Double(remaining) / averagePagesPerDay))
        return Calendar.current.date(byAdding: .day, value: daysNeeded, to: Date())
    }

    static var empty: ReadingProgress {
        ReadingProgress(
            dailyReadings: (1...30).map { day in
                DailyReading(day: day, juz: day, pagesRead: 0, totalPages: 20)
            },
            totalJuz: 30,
            totalPages: 604
        )
    }
}

#if DEBUG
extension ReadingProgress: PreviewData {
    static var preview: ReadingProgress {
        var progress = ReadingProgress.empty
        progress.dailyReadings = (1...30).map { day in
            DailyReading(day: day, juz: day, pagesRead: day <= 10 ? 20 : 0, totalPages: 20)
        }
        return progress
    }

    static var previewList: [ReadingProgress] { [preview] }
}
#endif
