import Foundation

enum PrayerName: String, CaseIterable, Codable, Identifiable {
    case fajr = "Fajr"
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .fajr: "sun.horizon"
        case .sunrise: "sunrise"
        case .dhuhr: "sun.max"
        case .asr: "sun.min"
        case .maghrib: "sunset"
        case .isha: "moon.stars"
        }
    }
    
    var emoji: String {
        switch self {
        case .fajr: return "🌅"
        case .sunrise: return "☀️"
        case .dhuhr: return "🌤️"
        case .asr: return "⛅"
        case .maghrib: return "🌇"
        case .isha: return "🌙"
        }
    }
    
    var hasAzan: Bool {
        switch self {
        case .sunrise: return false
        default: return true
        }
    }
}

typealias Prayer = PrayerName

struct PrayerTime: Identifiable {
    let id = UUID()
    let name: PrayerName
    let time: Date
    var azanEnabled: Bool = true
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    
    func countdown(from now: Date) -> String {
        let interval = time.timeIntervalSince(now)
        guard interval > 0 else { return "Passed" }
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    var isPassed: Bool { time < Date() }
}

struct DailyPrayerTimes: Codable {
    let date: Date
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
    
    var sehriTime: Date { fajr }
    var iftarTime: Date { maghrib }
    
    var allPrayers: [PrayerTime] {
        [
            PrayerTime(name: .fajr, time: fajr),
            PrayerTime(name: .sunrise, time: sunrise),
            PrayerTime(name: .dhuhr, time: dhuhr),
            PrayerTime(name: .asr, time: asr),
            PrayerTime(name: .maghrib, time: maghrib),
            PrayerTime(name: .isha, time: isha),
        ]
    }
    
    func time(for prayer: PrayerName) -> Date {
        switch prayer {
        case .fajr: return fajr
        case .sunrise: return sunrise
        case .dhuhr: return dhuhr
        case .asr: return asr
        case .maghrib: return maghrib
        case .isha: return isha
        }
    }
    
    func nextPrayer(after now: Date = Date()) -> PrayerTime? {
        allPrayers.first { $0.time > now }
    }
}
