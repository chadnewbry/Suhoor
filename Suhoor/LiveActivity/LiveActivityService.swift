import ActivityKit
import Foundation

@available(iOS 16.2, *)
final class LiveActivityService {
    static let shared = LiveActivityService()
    private var currentActivity: Activity<SuhoorActivityAttributes>?
    
    private init() {}
    
    func startLiveActivity(eventName: String, eventTime: Date, ramadanDay: Int, nextPrayerName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = SuhoorActivityAttributes(startDate: Date())
        let state = SuhoorActivityAttributes.ContentState(
            eventName: eventName,
            eventTime: eventTime,
            ramadanDay: ramadanDay,
            nextPrayerName: nextPrayerName
        )
        let content = ActivityContent(state: state, staleDate: eventTime)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Live Activity start error: \(error)")
        }
    }
    
    func updateLiveActivity(eventName: String, eventTime: Date, ramadanDay: Int, nextPrayerName: String) async {
        let state = SuhoorActivityAttributes.ContentState(
            eventName: eventName,
            eventTime: eventTime,
            ramadanDay: ramadanDay,
            nextPrayerName: nextPrayerName
        )
        let content = ActivityContent(state: state, staleDate: eventTime)
        await currentActivity?.update(content)
    }
    
    func endLiveActivity() async {
        await currentActivity?.end(nil, dismissalPolicy: .immediate)
        currentActivity = nil
    }
    
    /// Transition: when iftar passes, switch to sehri countdown and vice versa
    func transitionToNextEvent(prayerTimes: DailyPrayerTimes, ramadanDay: Int) async {
        let now = Date()
        if now < prayerTimes.iftarTime {
            await updateLiveActivity(
                eventName: "Iftar",
                eventTime: prayerTimes.iftarTime,
                ramadanDay: ramadanDay,
                nextPrayerName: prayerTimes.nextPrayer(after: now)?.prayer.displayName ?? "Maghrib"
            )
        } else {
            // After iftar, count down to next day's sehri (fajr)
            let nextSehri = Calendar.current.date(byAdding: .day, value: 1, to: prayerTimes.sehriTime) ?? prayerTimes.sehriTime
            await updateLiveActivity(
                eventName: "Sehri",
                eventTime: nextSehri,
                ramadanDay: ramadanDay + 1,
                nextPrayerName: "Fajr"
            )
        }
    }
}
