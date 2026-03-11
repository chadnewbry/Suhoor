import Foundation

struct HydrationEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    var glasses: Int
    var target: Int
    
    init(id: UUID = UUID(), date: Date = Date(), glasses: Int = 0, target: Int = 8) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.glasses = glasses
        self.target = target
    }
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(glasses) / Double(target), 1.0)
    }
}

#if DEBUG
extension HydrationEntry: PreviewData {
    static var preview: HydrationEntry {
        HydrationEntry(glasses: 5, target: 8)
    }
    
    static var previewList: [HydrationEntry] {
        let cal = Calendar.current
        let today = Date()
        return (0..<7).map { dayOffset in
            let date = cal.date(byAdding: .day, value: -dayOffset, to: today)!
            return HydrationEntry(date: date, glasses: Int.random(in: 3...8), target: 8)
        }
    }
}
#endif
