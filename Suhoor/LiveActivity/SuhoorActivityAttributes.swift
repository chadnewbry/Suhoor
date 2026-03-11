import ActivityKit
import Foundation

struct SuhoorActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let eventName: String      // "Iftar" or "Sehri"
        let eventTime: Date
        let ramadanDay: Int
        let nextPrayerName: String
    }
    
    let startDate: Date
}
