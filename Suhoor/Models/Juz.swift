import Foundation

struct Juz: Codable, Identifiable {
    let juzNumber: Int
    let name: String
    let startSurah: Int
    let startAyah: Int
    let endSurah: Int
    let endAyah: Int
    let pageCount: Int
    let ramadanDay: Int

    var id: Int { juzNumber }

    /// Returns the Juz assigned for a given Ramadan day (1-30)
    static func forRamadanDay(_ day: Int) -> Juz? {
        guard day >= 1 && day <= 30 else { return nil }
        return ContentService.shared.juzData.first { $0.ramadanDay == day }
    }
}
