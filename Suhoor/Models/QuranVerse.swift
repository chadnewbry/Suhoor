import Foundation

struct QuranVerse: Identifiable {
    let id = UUID()
    let arabic: String
    let translation: String
    let reference: String

    /// Returns the verse of the day based on the current Ramadan day (1–30),
    /// falling back to a rotation if outside Ramadan.
    static func verseOfTheDay(ramadanDay: Int? = nil) -> QuranVerse {
        let day = ramadanDay ?? {
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            return ((dayOfYear - 1) % 30) + 1
        }()

        if let verse = ContentService.shared.verse(forRamadanDay: day) {
            return QuranVerse(arabic: verse.arabic, translation: verse.translation, reference: verse.reference)
        }

        // Fallback
        return QuranVerse(
            arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            translation: "In the name of Allah, the Most Gracious, the Most Merciful.",
            reference: "Al-Fatiha 1:1"
        )
    }
}
