import Foundation
import SwiftData

@Model
final class HydrationEntry {
    var date: Date
    var amountMl: Int
    var timestamp: Date

    var fastingRecord: FastingRecord?

    init(date: Date, amountMl: Int, timestamp: Date) {
        self.date = date
        self.amountMl = amountMl
        self.timestamp = timestamp
    }
}

extension HydrationEntry {
    var isValid: Bool {
        amountMl > 0
    }
}
