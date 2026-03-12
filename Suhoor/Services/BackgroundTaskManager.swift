import Foundation
import BackgroundTasks

/// Manages background app refresh tasks to reschedule notifications daily.
@MainActor
final class BackgroundTaskManager {

    static let shared = BackgroundTaskManager()

    /// BGAppRefreshTask identifier — must match Info.plist BGTaskSchedulerPermittedIdentifiers.
    static let refreshTaskIdentifier = "com.chadnewbry.suhoor.refreshNotifications"

    private init() {}

    // MARK: - Registration

    /// Register the background refresh task with the system.
    /// Call this from `application(_:didFinishLaunchingWithOptions:)` or app init.
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.refreshTaskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            Task { @MainActor in
                self.handleAppRefresh(task: refreshTask)
            }
        }
    }

    // MARK: - Scheduling

    /// Schedule the next background app refresh. Targets early morning (3 AM)
    /// so notifications are refreshed before Fajr.
    func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskIdentifier)

        // Target 3 AM tomorrow for the next refresh
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.day! += 1
        components.hour = 3
        components.minute = 0
        if let targetDate = Calendar.current.date(from: components) {
            request.earliestBeginDate = targetDate
        }

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Background task scheduling can fail if the user has disabled
            // background app refresh; this is expected and non-fatal.
        }
    }

    // MARK: - Task Handling

    /// Handle the background refresh: reschedule all notifications and queue the next refresh.
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh before doing work
        scheduleNextRefresh()

        // Set expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // Reschedule all notifications
        NotificationManager.shared.scheduleAllNotifications()
        task.setTaskCompleted(success: true)
    }
}
