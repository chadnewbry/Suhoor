import Foundation

struct FastingDay: Identifiable {
    let id = UUID()
    let dayNumber: Int
    let totalDays: Int
    let hijriDate: String
    let gregorianDate: Date
    let sehriTime: Date
    let iftarTime: Date
    let completed: Bool
    
    var ashra: Ashra {
        switch dayNumber {
        case 1...10: return .first
        case 11...20: return .second
        default: return .third
        }
    }
    
    var monthProgress: Double {
        Double(dayNumber) / Double(totalDays)
    }
    
    func fastingProgress(at now: Date) -> Double {
        let total = iftarTime.timeIntervalSince(sehriTime)
        guard total > 0 else { return 0 }
        let elapsed = now.timeIntervalSince(sehriTime)
        return min(max(elapsed / total, 0), 1)
    }
    
    func timeToNextEvent(from now: Date) -> (label: String, remaining: TimeInterval) {
        if now < sehriTime {
            return ("Sehri in", sehriTime.timeIntervalSince(now))
        } else if now < iftarTime {
            return ("Iftar in", iftarTime.timeIntervalSince(now))
        } else {
            return ("Iftar passed", 0)
        }
    }
}

enum Ashra: String {
    case first = "First Ashra — Mercy"
    case second = "Second Ashra — Forgiveness"
    case third = "Third Ashra — Salvation"
}
