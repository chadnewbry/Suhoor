import Foundation
import SwiftData

enum DeedType: String, Codable, CaseIterable {
    case charity
    case extraPrayer
    case quranReading
    case dhikr
    case dua
    case custom
}

@Model
final class DeedEntry {
    var date: Date
    var deedTypeRaw: String
    var customLabel: String?
    var isCompleted: Bool
    var ramadanYear: Int

    var fastingRecord: FastingRecord?

    var deedType: DeedType {
        get { DeedType(rawValue: deedTypeRaw) ?? .custom }
        set { deedTypeRaw = newValue.rawValue }
    }

    init(
        date: Date,
        deedType: DeedType,
        customLabel: String? = nil,
        isCompleted: Bool = false,
        ramadanYear: Int
    ) {
        self.date = date
        self.deedTypeRaw = deedType.rawValue
        self.customLabel = customLabel
        self.isCompleted = isCompleted
        self.ramadanYear = ramadanYear
    }
}

extension DeedEntry {
    var displayLabel: String {
        if deedType == .custom, let customLabel, !customLabel.isEmpty {
            return customLabel
        }
        switch deedType {
        case .charity: return "Give Charity"
        case .extraPrayer: return "Extra Prayers (Tahajjud/Duha)"
        case .quranReading: return "Read Quran"
        case .dhikr: return "Dhikr (100x SubhanAllah, Alhamdulillah, Allahu Akbar)"
        case .dua: return "Make Dua for Others"
        case .custom: return "Custom"
        }
    }

    var displayEmoji: String {
        switch deedType {
        case .charity: return "💝"
        case .extraPrayer: return "🤲"
        case .quranReading: return "📖"
        case .dhikr: return "📿"
        case .dua: return "✨"
        case .custom: return "⭐"
        }
    }
}
