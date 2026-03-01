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

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .streak7: return "7-Day Streak"
        case .streak15: return "15-Day Streak"
        case .streak30: return "30-Day Streak"
        case .fullAshra1: return "First Ashra Complete"
        case .fullAshra2: return "Second Ashra Complete"
        case .fullAshra3: return "Third Ashra Complete"
        case .khatam: return "Quran Khatam"
        case .allFasted: return "All Days Fasted"
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
