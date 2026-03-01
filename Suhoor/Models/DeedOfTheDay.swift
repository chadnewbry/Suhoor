import Foundation

struct DeedOfTheDay: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let emoji: String
    
    static let deeds: [DeedOfTheDay] = [
        DeedOfTheDay(title: "Feed Someone Iftar", description: "The Prophet ﷺ said: Whoever feeds a fasting person will have a reward like that of the fasting person.", emoji: "🍽️"),
        DeedOfTheDay(title: "Extra Night Prayers", description: "Stand in Taraweeh and Tahajjud tonight. Every prostration brings you closer.", emoji: "🤲"),
        DeedOfTheDay(title: "Give Sadaqah", description: "Even a small charity extinguishes sin as water extinguishes fire.", emoji: "💝"),
        DeedOfTheDay(title: "Recite Quran", description: "Ramadan is the month of the Quran. Read even a single page today.", emoji: "📖"),
        DeedOfTheDay(title: "Make Dua at Iftar", description: "The supplication of the fasting person at the time of breaking fast is not rejected.", emoji: "✨"),
        DeedOfTheDay(title: "Forgive Someone", description: "This is the Ashra of Forgiveness. Let go of a grudge today.", emoji: "🕊️"),
        DeedOfTheDay(title: "Visit the Sick", description: "Visiting the sick is one of the rights of a Muslim upon another.", emoji: "💐"),
    ]
    
    static func deedOfTheDay() -> DeedOfTheDay {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return deeds[dayOfYear % deeds.count]
    }
}
