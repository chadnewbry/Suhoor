import Foundation

/// Provides bundled Quran, dua, verse, and meal content from JSON resources.
final class ContentService {
    static let shared = ContentService()

    let juzData: [Juz]
    let duas: DuasCollection
    let dailyVerses: [DailyVerse]
    let suhoorMeals: [SuhoorMeal]

    private init() {
        juzData = Self.load("juz_data")
        duas = Self.loadSingle("duas")
        dailyVerses = Self.load("daily_verses")
        suhoorMeals = Self.load("suhoor_meals")
    }

    // MARK: - Juz

    /// Returns the Juz for a given Ramadan day (1–30).
    func juz(forRamadanDay day: Int) -> Juz? {
        juzData.first { $0.ramadanDay == day }
    }

    /// Returns all 30 Juz in order.
    var allJuz: [Juz] { juzData }

    // MARK: - Duas

    /// Returns the appropriate Ashra dua for a given Ramadan day.
    func ashraDua(forRamadanDay day: Int) -> AshraDua? {
        switch day {
        case 1...10: return duas.ashras.first { $0.ashra == 1 }
        case 11...20: return duas.ashras.first { $0.ashra == 2 }
        case 21...30: return duas.ashras.first { $0.ashra == 3 }
        default: return nil
        }
    }

    // MARK: - Daily Verse

    /// Returns the verse for a given Ramadan day (1–30).
    func verse(forRamadanDay day: Int) -> DailyVerse? {
        dailyVerses.first { $0.day == day }
    }

    // MARK: - Suhoor Meals

    /// Returns the meal suggestion for a given Ramadan day (1–30).
    func meal(forRamadanDay day: Int) -> SuhoorMeal? {
        suhoorMeals.first { $0.day == day }
    }

    // MARK: - JSON Loading

    private static func load<T: Decodable>(_ resource: String) -> [T] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func loadSingle<T: Decodable>(_ resource: String) -> T {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Failed to load \(resource).json from bundle")
        }
        return decoded
    }
}
