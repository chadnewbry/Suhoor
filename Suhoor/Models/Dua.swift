import Foundation

// MARK: - Dua Category

enum DuaCategory: String, Codable, CaseIterable, Identifiable {
    case sehri = "Sehri"
    case iftar = "Iftar"
    case laylatAlQadr = "Laylat al-Qadr"
    case firstAshra = "First Ashra"
    case secondAshra = "Second Ashra"
    case thirdAshra = "Third Ashra"
    case general = "General Ramadan"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .sehri: return "🌙"
        case .iftar: return "🍽️"
        case .laylatAlQadr: return "✨"
        case .firstAshra: return "🤲"
        case .secondAshra: return "🕊️"
        case .thirdAshra: return "🔥"
        case .general: return "📿"
        }
    }

    var localizedKey: String {
        switch self {
        case .sehri: return "dua_category_sehri"
        case .iftar: return "dua_category_iftar"
        case .laylatAlQadr: return "dua_category_laylat"
        case .firstAshra: return "dua_category_first_ashra"
        case .secondAshra: return "dua_category_second_ashra"
        case .thirdAshra: return "dua_category_third_ashra"
        case .general: return "dua_category_general"
        }
    }
}

// MARK: - Dua

struct Dua: Codable, Identifiable {
    let id: String
    let category: DuaCategory
    let arabicText: String
    let transliteration: String
    let englishTranslation: String
    let reference: String?
    let audioFileName: String?
    let audioURL: String?

    var hasAudio: Bool {
        audioFileName != nil || audioURL != nil
    }
}

// MARK: - Dua Collection

struct DuaCollection: Codable {
    let duas: [Dua]

    func duas(for category: DuaCategory) -> [Dua] {
        duas.filter { $0.category == category }
    }

    var categories: [DuaCategory] {
        let found = Set(duas.map(\.category))
        return DuaCategory.allCases.filter { found.contains($0) }
    }
}

#if DEBUG
extension Dua: PreviewData {
    static var preview: Dua {
        Dua(
            id: "iftar_1",
            category: .iftar,
            arabicText: "اللَّهُمَّ إِنِّي لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ",
            transliteration: "Allahumma inni laka sumtu wa bika aamantu wa ala rizqika aftartu",
            englishTranslation: "O Allah! I fasted for You and I believe in You and I break my fast with Your sustenance.",
            reference: "Abu Dawud",
            audioFileName: nil,
            audioURL: nil
        )
    }

    static var previewList: [Dua] {
        [
            preview,
            Dua(id: "sehri_1", category: .sehri,
                arabicText: "وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ",
                transliteration: "Wa bisawmi ghadinn nawaiytu min shahri ramadan",
                englishTranslation: "I intend to keep the fast for tomorrow in the month of Ramadan.",
                reference: "Abu Dawud", audioFileName: nil, audioURL: nil),
            Dua(id: "general_1", category: .general,
                arabicText: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
                transliteration: "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar",
                englishTranslation: "Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.",
                reference: "Quran 2:201", audioFileName: nil, audioURL: nil),
        ]
    }
}
#endif
