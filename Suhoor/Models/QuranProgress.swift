import Foundation
import SwiftData

@Model
final class QuranProgress {
    @Attribute(.unique) var date: Date
    var juzNumber: Int
    var isCompleted: Bool
    var pagesRead: Int
    var readingDurationMinutes: Int?
    var ramadanYear: Int

    init(
        date: Date,
        juzNumber: Int,
        isCompleted: Bool = false,
        pagesRead: Int = 0,
        readingDurationMinutes: Int? = nil,
        ramadanYear: Int
    ) {
        self.date = date
        self.juzNumber = juzNumber
        self.isCompleted = isCompleted
        self.pagesRead = pagesRead
        self.readingDurationMinutes = readingDurationMinutes
        self.ramadanYear = ramadanYear
    }
}

extension QuranProgress {
    var isValid: Bool {
        juzNumber >= 1 && juzNumber <= 30 && pagesRead >= 0
    }
}
