import Foundation

// MARK: - Prayer (from HEAD)

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

    var systemImage: String {
        switch self {
        case .fajr: return "sun.horizon"
        case .sunrise: return "sunrise"
        case .dhuhr: return "sun.max"
        case .asr: return "sun.min"
        case .maghrib: return "sunset"
        case .isha: return "moon.stars"
        }
    }
}

// MARK: - PrayerName (from main)

enum PrayerName: String, CaseIterable, Identifiable {
    case fajr = "Fajr"
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"

    var id: String { rawValue }

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
}

// MARK: - PrayerTime (from HEAD)

struct PrayerTime: Identifiable, Codable {
    var id: String { prayer.rawValue + "-" + date.timeIntervalSince1970.description }
    let prayer: Prayer
    let date: Date
    let time: Date

    var isPassed: Bool { time < Date() }

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
}

// MARK: - DailyPrayerTimes (from HEAD)

struct DailyPrayerTimes: Codable {
    let date: Date
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
    let imsak: Date
    let iftar: Date
    let taraweeh: Date

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

// MARK: - SimplePrayerTime (from main, renamed to avoid conflict)

struct SimplePrayerTime: Identifiable {
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
}
