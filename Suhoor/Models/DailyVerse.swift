import Foundation

struct DailyVerse: Codable, Identifiable {
    let day: Int
    let arabic: String
    let translation: String
    let reference: String

    var id: Int { day }
}
