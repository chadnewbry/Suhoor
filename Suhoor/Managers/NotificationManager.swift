import Foundation
import SwiftUI
import Combine

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var settings = NotificationSettings.load()
    @Published var isPermissionGranted = false
    
    private let notificationService = NotificationService.shared
    
    private init() {}
    
    func setup() async {
        let status = await notificationService.checkPermission()
        isPermissionGranted = status == .authorized
        
        if !isPermissionGranted {
            isPermissionGranted = await notificationService.requestPermission()
        }
    }
    
    func saveAndReschedule(prayerTimes: DailyPrayerTimes) async {
        settings.save()
        await notificationService.scheduleAllNotifications(for: prayerTimes, settings: settings)
        
        // Update shared data for widgets
        updateSharedData(prayerTimes: prayerTimes)
        
        // Start/update Live Activity
        if #available(iOS 16.2, *) {
            let info = RamadanInfo.current()
            let now = Date()
            let eventName = now < prayerTimes.iftarTime ? "Iftar" : "Sehri"
            let eventTime = now < prayerTimes.iftarTime ? prayerTimes.iftarTime : prayerTimes.sehriTime
            
            LiveActivityService.shared.startLiveActivity(
                eventName: eventName,
                eventTime: eventTime,
                ramadanDay: info.dayNumber,
                nextPrayerName: prayerTimes.nextPrayer()?.prayer.displayName ?? "Fajr"
            )
        }
    }
    
    private func updateSharedData(prayerTimes: DailyPrayerTimes) {
        let now = Date()
        let nextPrayer = prayerTimes.nextPrayer(after: now)
        let info = RamadanInfo.current()
        
        let upcoming = prayerTimes.allPrayers
            .filter { !$0.isPassed }
            .prefix(3)
            .map { SharedData.SharedPrayerEntry(name: $0.prayer.displayName, emoji: $0.prayer.emoji, time: $0.time, isPassed: false) }
        
        let shared = SharedData(
            nextPrayerName: nextPrayer?.prayer.displayName ?? "Fajr",
            nextPrayerTime: nextPrayer?.time ?? prayerTimes.fajr,
            iftarTime: prayerTimes.iftarTime,
            sehriTime: prayerTimes.sehriTime,
            ramadanDay: info.dayNumber,
            fastingStreak: UserDefaults(suiteName: SharedData.suiteName)?.integer(forKey: "fasting_streak") ?? 0,
            quranProgress: UserDefaults(suiteName: SharedData.suiteName)?.double(forKey: "quran_progress") ?? 0.0,
            upcomingPrayers: Array(upcoming),
            lastUpdated: now
        )
        shared.save()
    }
}
