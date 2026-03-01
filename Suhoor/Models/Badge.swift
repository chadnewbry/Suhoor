import Foundation
import SwiftData

// MARK: - Badge Type

enum BadgeType: String, Codable, CaseIterable, Identifiable {
    case streak7
    case streak15
    case streak30
    case fullAshra1
    case fullAshra2
    case fullAshra3
    case khatam
    case allFasted
    case deedMaster

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .streak7: return "7-Day Streak"
        case .streak15: return "15-Day Streak"
        case .streak30: return "Full Ramadan"
        case .fullAshra1: return "1st Ashra Complete"
        case .fullAshra2: return "2nd Ashra Complete"
        case .fullAshra3: return "3rd Ashra Complete"
        case .khatam: return "Khatam"
        case .allFasted: return "All Days Fasted"
        case .deedMaster: return "Deed Master"
        }
    }

    var description: String {
        switch self {
        case .streak7: return "Fasted 7 days in a row"
        case .streak15: return "Fasted 15 days in a row"
        case .streak30: return "Fasted all 30 days"
        case .fullAshra1: return "Completed the 1st Ashra (Mercy)"
        case .fullAshra2: return "Completed the 2nd Ashra (Forgiveness)"
        case .fullAshra3: return "Completed the 3rd Ashra (Salvation)"
        case .khatam: return "Completed the entire Quran"
        case .allFasted: return "Fasted every single day"
        case .deedMaster: return "All deeds every day for a week"
        }
    }

    var emoji: String {
        switch self {
        case .streak7: return "🔥"
        case .streak15: return "⚡"
        case .streak30: return "🏆"
        case .fullAshra1: return "🌅"
        case .fullAshra2: return "🌙"
        case .fullAshra3: return "⭐"
        case .khatam: return "📖"
        case .allFasted: return "👑"
        case .deedMaster: return "💎"
        }
    }

    var streakThreshold: Int? {
        switch self {
        case .streak7: return 7
        case .streak15: return 15
        case .streak30: return 30
        default: return nil
        }
    }
}

// MARK: - Badge Model

@Model
final class Badge {
    var badgeTypeRaw: String
    var earnedDate: Date
    var ramadanYear: Int

    var badgeType: BadgeType {
        get { BadgeType(rawValue: badgeTypeRaw) ?? .streak7 }
        set { badgeTypeRaw = newValue.rawValue }
    }

    init(badgeType: BadgeType, earnedDate: Date = .now, ramadanYear: Int) {
        self.badgeTypeRaw = badgeType.rawValue
        self.earnedDate = earnedDate
        self.ramadanYear = ramadanYear
    }
}
