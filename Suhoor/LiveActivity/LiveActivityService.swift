import ActivityKit
import Foundation
import WidgetKit

@available(iOS 16.2, *)
final class LiveActivityService {
    static let shared = LiveActivityService()
    private var currentActivity: Activity<SuhoorActivityAttributes>?
    
    private init() {}
    
    // MARK: - Core Operations
    
    func startLiveActivity(eventName: String, eventTime: Date, ramadanDay: Int, nextPrayerName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        // End any existing activity first
        Task { await endLiveActivity() }
        
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
    
    // MARK: - Auto-Start & Daily Management
    
    /// Called on app launch and at each prayer time transition.
    /// Automatically starts or updates the Live Activity based on current time.
    func syncWithPrayerTimes(_ prayerTimes: DailyPrayerTimes, ramadanDay: Int) {
        let now = Date()
        
        // Only run during Ramadan
        let islamic = Calendar(identifier: .islamicUmmAlQura)
        let month = islamic.component(.month, from: now)
        guard month == 9 else {
            Task { await endLiveActivity() }
            return
        }
        
        if now < prayerTimes.iftarTime {
            // Before iftar: show iftar countdown
            let nextPrayer = prayerTimes.nextPrayer(after: now)
            startLiveActivity(
                eventName: "Iftar",
                eventTime: prayerTimes.iftarTime,
                ramadanDay: ramadanDay,
                nextPrayerName: nextPrayer?.prayer.displayName ?? "Maghrib"
            )
        } else {
            // After iftar: show sehri countdown for tomorrow
            let cal = Calendar.current
            let nextSehri = cal.date(byAdding: .day, value: 1, to: prayerTimes.sehriTime) ?? prayerTimes.sehriTime
            startLiveActivity(
                eventName: "Sehri",
                eventTime: nextSehri,
                ramadanDay: ramadanDay + 1,
                nextPrayerName: "Fajr"
            )
        }
        
        // Also trigger widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Transition: when a prayer time passes, update the Live Activity
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
