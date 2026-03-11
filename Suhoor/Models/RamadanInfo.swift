import Foundation

struct RamadanInfo: Codable {
    let dayNumber: Int
    let totalDays: Int
    let hijriDate: String
    
    static func current(for date: Date = Date()) -> RamadanInfo {
        let islamic = Calendar(identifier: .islamicUmmAlQura)
        let comps = islamic.dateComponents([.month, .day], from: date)
        let day = (comps.month == 9) ? (comps.day ?? 1) : 1
        return RamadanInfo(dayNumber: day, totalDays: 30, hijriDate: "Ramadan \(day)")
    }
    
    var isRamadan: Bool {
        let islamic = Calendar(identifier: .islamicUmmAlQura)
        let comps = islamic.dateComponents([.month], from: Date())
        return comps.month == 9
    }
}
