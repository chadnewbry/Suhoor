import Foundation
import SwiftData

@Model
final class MakeupFast {
    var originalDate: Date
    var reason: String
    var completedDate: Date?
    var isCompleted: Bool

    var originalFastingRecord: FastingRecord?

    init(
        originalDate: Date,
        reason: String,
        completedDate: Date? = nil,
        isCompleted: Bool = false
    ) {
        self.originalDate = originalDate
        self.reason = reason
        self.completedDate = completedDate
        self.isCompleted = isCompleted
    }
}

extension MakeupFast {
    var isPending: Bool { !isCompleted }
}
