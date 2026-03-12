import Foundation

/// Lightweight location value stored in UserDefaults via Codable.
struct LocationData: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var name: String?
    var timeZoneIdentifier: String?

    var timeZone: TimeZone? {
        timeZoneIdentifier.flatMap { TimeZone(identifier: $0) }
    }
}
