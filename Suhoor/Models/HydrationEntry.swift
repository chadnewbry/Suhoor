import Foundation
import SwiftData

@Model
final class HydrationEntry {
    var date: Date
    var amountMl: Int
    var glassesCount: Int
    var targetGlasses: Int
    var timestamp: Date

    var fastingRecord: FastingRecord?

    init(
        date: Date,
        amountMl: Int = 0,
        glassesCount: Int = 0,
        targetGlasses: Int = 8,
        timestamp: Date = .now
    ) {
        self.date = date
        self.amountMl = amountMl
        self.glassesCount = glassesCount
        self.targetGlasses = targetGlasses
        self.timestamp = timestamp
    }
}

extension HydrationEntry {
    var isValid: Bool { amountMl > 0 || glassesCount > 0 }
    var progress: Double { targetGlasses > 0 ? Double(glassesCount) / Double(targetGlasses) : 0 }
}
