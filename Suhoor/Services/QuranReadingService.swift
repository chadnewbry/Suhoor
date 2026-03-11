import Foundation

final class QuranReadingService: ObservableObject {
    static let shared = QuranReadingService()

    @Published private(set) var progress: ReadingProgress
    @Published private(set) var juzMap: [JuzInfo] = []

    private let progressKey = "quran_reading_progress"

    private init() {
        self.progress = ReadingProgress.empty
        loadJuzMapping()
        loadProgress()
    }

    // MARK: - Data Loading

    private func loadJuzMapping() {
        guard let url = Bundle.main.url(forResource: "juz_mapping", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let mapping = try? JSONDecoder().decode([JuzInfo].self, from: data) else {
            return
        }
        juzMap = mapping
    }

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let saved = try? JSONDecoder().decode(ReadingProgress.self, from: data) else {
            return
        }
        progress = saved
    }

    private func saveProgress() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: progressKey)
    }

    // MARK: - Actions

    func updatePagesRead(day: Int, pages: Int) {
        guard let index = progress.dailyReadings.firstIndex(where: { $0.day == day }) else { return }
        let reading = progress.dailyReadings[index]
        progress.dailyReadings[index] = DailyReading(
            day: reading.day,
            juz: reading.juz,
            pagesRead: min(pages, reading.totalPages),
            totalPages: reading.totalPages
        )
        saveProgress()
    }

    func markDayComplete(day: Int) {
        guard let index = progress.dailyReadings.firstIndex(where: { $0.day == day }) else { return }
        let reading = progress.dailyReadings[index]
        progress.dailyReadings[index] = DailyReading(
            day: reading.day,
            juz: reading.juz,
            pagesRead: reading.totalPages,
            totalPages: reading.totalPages
        )
        saveProgress()
    }

    func resetProgress() {
        progress = ReadingProgress.empty
        saveProgress()
    }

    func juzInfo(for day: Int) -> JuzInfo? {
        juzMap.first { $0.juz == day }
    }
}
