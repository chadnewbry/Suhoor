import Foundation

struct QuranVerse: Identifiable {
    let id = UUID()
    let arabic: String
    let translation: String
    let reference: String
    
    static let ramadanVerses: [QuranVerse] = [
        QuranVerse(
            arabic: "يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِن قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ",
            translation: "O you who believe! Fasting is prescribed for you as it was prescribed for those before you, that you may attain Taqwa.",
            reference: "Al-Baqarah 2:183"
        ),
        QuranVerse(
            arabic: "شَهْرُ رَمَضَانَ الَّذِي أُنزِلَ فِيهِ الْقُرْآنُ هُدًى لِّلنَّاسِ وَبَيِّنَاتٍ مِّنَ الْهُدَىٰ وَالْفُرْقَانِ",
            translation: "The month of Ramadan in which the Quran was revealed, a guidance for the people and clear proofs of guidance and criterion.",
            reference: "Al-Baqarah 2:185"
        ),
        QuranVerse(
            arabic: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ",
            translation: "And when My servants ask you concerning Me — indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.",
            reference: "Al-Baqarah 2:186"
        ),
        QuranVerse(
            arabic: "إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ",
            translation: "Indeed, We sent it down during the Night of Decree. The Night of Decree is better than a thousand months.",
            reference: "Al-Qadr 97:1-3"
        ),
        QuranVerse(
            arabic: "وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ",
            translation: "And seek help through patience and prayer, and indeed it is difficult except for the humbly submissive.",
            reference: "Al-Baqarah 2:45"
        ),
        QuranVerse(
            arabic: "فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ",
            translation: "So remember Me; I will remember you. And be grateful to Me and do not deny Me.",
            reference: "Al-Baqarah 2:152"
        ),
    ]
    
    static func verseOfTheDay() -> QuranVerse {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return ramadanVerses[dayOfYear % ramadanVerses.count]
    }
}
