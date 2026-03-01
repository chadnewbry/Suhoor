import Foundation
import SwiftData

// MARK: - Fasting Status

enum FastingStatus: String, Codable, CaseIterable {
    case fasted
    case missed
    case excused
}

// MARK: - Excuse Reason

enum ExcuseReason: String, Codable, CaseIterable {
    case menstruation
    case travel
    case illness
    case other
}

// MARK: - Fasting Record

@Model
final class FastingRecord {
    @Attribute(.unique) var date: Date
    var dayNumber: Int
    var statusRaw: String
    var excuseReasonRaw: String?
    var notes: String?
    var fastStartTime: Date
    var fastEndTime: Date
    var fastDurationHours: Double

    @Relationship(deleteRule: .cascade, inverse: \MakeupFast.originalFastingRecord)
    var makeupFast: MakeupFast?

    @Relationship(deleteRule: .cascade, inverse: \HydrationEntry.fastingRecord)
    var hydrationEntries: [HydrationEntry]

    @Relationship(deleteRule: .cascade, inverse: \DeedEntry.fastingRecord)
    var deedEntries: [DeedEntry]

    var status: FastingStatus {
        get { FastingStatus(rawValue: statusRaw) ?? .missed }
        set { statusRaw = newValue.rawValue }
    }

    var excuseReason: ExcuseReason? {
        get { excuseReasonRaw.flatMap { ExcuseReason(rawValue: $0) } }
        set { excuseReasonRaw = newValue?.rawValue }
    }

    init(
        date: Date,
        dayNumber: Int,
        status: FastingStatus = .fasted,
        excuseReason: ExcuseReason? = nil,
        notes: String? = nil,
        fastStartTime: Date,
        fastEndTime: Date,
        fastDurationHours: Double
    ) {
        self.date = date
        self.dayNumber = dayNumber
        self.statusRaw = status.rawValue
        self.excuseReasonRaw = excuseReason?.rawValue
        self.notes = notes
        self.fastStartTime = fastStartTime
        self.fastEndTime = fastEndTime
        self.fastDurationHours = fastDurationHours
        self.hydrationEntries = []
        self.deedEntries = []
    }
}

// MARK: - Validation

extension FastingRecord {
    var isValid: Bool {
        dayNumber >= 1 && dayNumber <= 30
            && fastStartTime < fastEndTime
            && fastDurationHours > 0
            && (status != .excused || excuseReason != nil)
    }
}
