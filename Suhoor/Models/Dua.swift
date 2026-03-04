import Foundation

struct Dua: Codable, Identifiable {
    var id: String { transliteration }
    let arabic: String
    let transliteration: String
    let translation: String
    let reference: String
}

struct AshraDua: Codable, Identifiable {
    let ashra: Int
    let name: String
    let days: String
    let arabic: String
    let transliteration: String
    let translation: String
    let reference: String

    var id: Int { ashra }
}

struct ExcusedDayDua: Codable, Identifiable {
    var id: String { title }
    let title: String
    let arabic: String
    let transliteration: String
    let translation: String
    let reference: String
}

struct DuasCollection: Codable {
    let sehriDua: Dua
    let iftarDua: Dua
    let iftarDuaAlternate: Dua
    let ashras: [AshraDua]
    let laylatAlQadr: [Dua]
    let excusedDays: [ExcusedDayDua]
}
