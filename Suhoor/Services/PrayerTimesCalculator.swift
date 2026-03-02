import Foundation
import CoreLocation

// MARK: - Calculation Method Parameters

struct CalculationParameters {
    let fajrAngle: Double
    let ishaAngle: Double
    let ishaInterval: Int?
    let maghribAngle: Double?

    static func parameters(for method: CalculationMethod) -> CalculationParameters {
        switch method {
        case .muslimWorldLeague:
            CalculationParameters(fajrAngle: 18.0, ishaAngle: 17.0, ishaInterval: nil, maghribAngle: nil)
        case .egyptian:
            CalculationParameters(fajrAngle: 19.5, ishaAngle: 17.5, ishaInterval: nil, maghribAngle: nil)
        case .karachi:
            CalculationParameters(fajrAngle: 18.0, ishaAngle: 18.0, ishaInterval: nil, maghribAngle: nil)
        case .ummAlQura:
            CalculationParameters(fajrAngle: 18.5, ishaAngle: 0, ishaInterval: 90, maghribAngle: nil)
        case .dubai:
            CalculationParameters(fajrAngle: 18.2, ishaAngle: 18.2, ishaInterval: nil, maghribAngle: nil)
        case .qatar:
            CalculationParameters(fajrAngle: 18.0, ishaAngle: 0, ishaInterval: 90, maghribAngle: nil)
        case .kuwait:
            CalculationParameters(fajrAngle: 18.0, ishaAngle: 17.5, ishaInterval: nil, maghribAngle: nil)
        case .moonsightingCommittee:
            CalculationParameters(fajrAngle: 18.0, ishaAngle: 18.0, ishaInterval: nil, maghribAngle: nil)
        case .singapore:
            CalculationParameters(fajrAngle: 20.0, ishaAngle: 18.0, ishaInterval: nil, maghribAngle: nil)
        case .turkey:
            CalculationParameters(fajrAngle: 18.0, ishaAngle: 17.0, ishaInterval: nil, maghribAngle: nil)
        case .tehran:
            CalculationParameters(fajrAngle: 17.7, ishaAngle: 14.0, ishaInterval: nil, maghribAngle: 4.5)
        case .northAmerica:
            CalculationParameters(fajrAngle: 15.0, ishaAngle: 15.0, ishaInterval: nil, maghribAngle: nil)
        case .jafari:
            CalculationParameters(fajrAngle: 16.0, ishaAngle: 14.0, ishaInterval: nil, maghribAngle: 4.0)
        }
    }
}

// MARK: - Daily Prayer Times Result

struct DailyPrayerTimes {
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
}

// MARK: - Prayer Times Calculator

/// Astronomical prayer times calculation engine using standard solar position algorithms.
final class PrayerTimesCalculator {

    static let shared = PrayerTimesCalculator()
    private init() {}

    // MARK: - Public API

    func calculate(
        for date: Date,
        coordinate: CLLocationCoordinate2D,
        timeZone: TimeZone,
        method: CalculationMethod,
        madhhab: Madhhab,
        imsakMinutesBefore: Int = 10,
        taraweehMinutesAfterIsha: Int = 90
    ) -> DailyPrayerTimes {
        let cal = Calendar.current
        let params = CalculationParameters.parameters(for: method)
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let jd = julianDate(for: date, calendar: cal)
        let utcOffset = Double(timeZone.secondsFromGMT(for: date)) / 3600.0
        let (declination, eqTime) = sunPosition(jd: jd)

        let transit = 12.0 + (-eqTime / 60.0) - (longitude / 15.0) + utcOffset
        let sunriseHour = transit - hourAngle(latitude: latitude, declination: declination, angle: 0.8333) / 15.0
        let sunsetHour = transit + hourAngle(latitude: latitude, declination: declination, angle: 0.8333) / 15.0
        let fajrHour = transit - hourAngle(latitude: latitude, declination: declination, angle: params.fajrAngle) / 15.0

        let shadowFactor: Double = (madhhab == .hanafi) ? 2.0 : 1.0
        let asrAngle = atan(1.0 / (shadowFactor + tan(abs(latitude - declination) * .pi / 180.0))) * 180.0 / .pi
        let asrHour = transit + hourAngle(latitude: latitude, declination: declination, angle: asrAngle) / 15.0

        let maghribHour: Double
        if let mAngle = params.maghribAngle {
            maghribHour = transit + hourAngle(latitude: latitude, declination: declination, angle: mAngle) / 15.0
        } else {
            maghribHour = sunsetHour
        }

        let ishaHour: Double
        if let interval = params.ishaInterval {
            ishaHour = maghribHour + Double(interval) / 60.0
        } else {
            ishaHour = transit + hourAngle(latitude: latitude, declination: declination, angle: params.ishaAngle) / 15.0
        }

        func toDate(_ hours: Double) -> Date {
            let startOfDay = cal.startOfDay(for: date)
            let totalSeconds = Int(hours * 3600)
            return startOfDay.addingTimeInterval(Double(totalSeconds))
        }

        let fajr = toDate(fajrHour)
        let sunrise = toDate(sunriseHour)
        let dhuhr = toDate(transit)
        let asr = toDate(asrHour)
        let maghrib = toDate(maghribHour)
        let isha = toDate(ishaHour)
        let imsak = fajr.addingTimeInterval(Double(-imsakMinutesBefore) * 60)
        let taraweeh = isha.addingTimeInterval(Double(taraweehMinutesAfterIsha) * 60)

        return DailyPrayerTimes(
            date: date,
            fajr: fajr, sunrise: sunrise, dhuhr: dhuhr, asr: asr,
            maghrib: maghrib, isha: isha,
            imsak: imsak, iftar: maghrib, taraweeh: taraweeh
        )
    }

    // MARK: - Solar Calculations

    private func julianDate(for date: Date, calendar: Calendar) -> Double {
        var y = Double(calendar.component(.year, from: date))
        var m = Double(calendar.component(.month, from: date))
        let day = Double(calendar.component(.day, from: date))
        if m <= 2 { y -= 1; m += 12 }
        let a = floor(y / 100.0)
        let b = 2.0 - a + floor(a / 4.0)
        return floor(365.25 * (y + 4716.0)) + floor(30.6001 * (m + 1.0)) + day + b - 1524.5
    }

    private func sunPosition(jd: Double) -> (Double, Double) {
        let d = jd - 2451545.0
        let l0 = (280.46646 + 0.9856474 * d).truncatingRemainder(dividingBy: 360.0)
        let m = (357.52911 + 0.98560028 * d).truncatingRemainder(dividingBy: 360.0)
        let mRad = m * .pi / 180.0
        let c = (1.9146 - 0.004817 * d / 36525.0) * sin(mRad)
            + 0.019993 * sin(2.0 * mRad)
            + 0.00029 * sin(3.0 * mRad)
        let sunLon = l0 + c
        let obliquity = 23.439 - 0.00000036 * d
        let oblRad = obliquity * .pi / 180.0
        let sunLonRad = sunLon * .pi / 180.0
        let declination = asin(sin(oblRad) * sin(sunLonRad)) * 180.0 / .pi
        let ra = atan2(cos(oblRad) * sin(sunLonRad), cos(sunLonRad)) * 180.0 / .pi
        var eqTime = l0 - ra
        while eqTime > 180 { eqTime -= 360 }
        while eqTime < -180 { eqTime += 360 }
        eqTime *= 4.0
        return (declination, eqTime)
    }

    private func hourAngle(latitude: Double, declination: Double, angle: Double) -> Double {
        let latRad = latitude * .pi / 180.0
        let decRad = declination * .pi / 180.0
        let angleRad = angle * .pi / 180.0
        let cosHA = (sin(angleRad) - sin(latRad) * sin(decRad)) / (cos(latRad) * cos(decRad))
        if cosHA > 1.0 { return 0.0 }
        if cosHA < -1.0 { return 180.0 }
        return acos(-cosHA) * 180.0 / .pi
    }
}
