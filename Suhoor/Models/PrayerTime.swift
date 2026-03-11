import Foundation

enum Prayer: String, CaseIterable, Codable, Identifiable {
    case fajr = "Fajr"
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
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

struct PrayerTime: Identifiable, Codable {
    var id: String { prayer.rawValue + "-" + date.timeIntervalSince1970.description }
    let prayer: Prayer
    let date: Date
    let time: Date
    
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
            PrayerTime(prayer: .fajr, date: date, time: fajr),
            PrayerTime(prayer: .sunrise, date: date, time: sunrise),
            PrayerTime(prayer: .dhuhr, date: date, time: dhuhr),
            PrayerTime(prayer: .asr, date: date, time: asr),
            PrayerTime(prayer: .maghrib, date: date, time: maghrib),
            PrayerTime(prayer: .isha, date: date, time: isha),
        ]
    }
    
    func time(for prayer: Prayer) -> Date {
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
