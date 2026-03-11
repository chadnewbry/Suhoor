import Foundation

struct ChecklistItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var minutesBefore: Int // minutes before sehri time to alert
    var isDefault: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, minutesBefore: Int = 30, isDefault: Bool = true) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.minutesBefore = minutesBefore
        self.isDefault = isDefault
    }
    
    static let defaults: [ChecklistItem] = [
        ChecklistItem(title: "Eat suhoor", minutesBefore: 45),
        ChecklistItem(title: "Drink water", minutesBefore: 40),
        ChecklistItem(title: "Pray Tahajjud", minutesBefore: 60),
        ChecklistItem(title: "Make dua", minutesBefore: 20),
        ChecklistItem(title: "Brush teeth", minutesBefore: 10),
    ]
}

struct DailyChecklistData: Codable, Identifiable {
    var id: String { dateKey }
    let dateKey: String // yyyy-MM-dd
    var items: [ChecklistItem]
    
    var completionCount: Int { items.filter(\.isCompleted).count }
    var isFullyCompleted: Bool { items.allSatisfy(\.isCompleted) }
    
    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#if DEBUG
extension ChecklistItem: PreviewData {
    static var preview: ChecklistItem { defaults[0] }
    static var previewList: [ChecklistItem] { defaults }
}
#endif
