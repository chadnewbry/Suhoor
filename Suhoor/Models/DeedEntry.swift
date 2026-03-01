import Foundation
import SwiftData

enum DeedType: String, Codable, CaseIterable {
    case charity
    case extraPrayer
    case quranReading
    case dhikr
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
        case .charity: return "Charity"
        case .extraPrayer: return "Extra Prayer"
        case .quranReading: return "Quran Reading"
        case .dhikr: return "Dhikr"
        case .custom: return "Custom"
        }
    }
}
