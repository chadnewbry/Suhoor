import SwiftUI

@main
struct SuhoorApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var userPreferences = UserPreferences.shared
    @State private var notificationManager = NotificationManager.shared

    /// Track scene phase to reschedule notifications when app becomes active.
    @Environment(\.scenePhase) private var scenePhase

    init() {
        BackgroundTaskManager.shared.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .preferredColorScheme(.dark)
                } else {
                    OnboardingView()
                        .preferredColorScheme(.dark)
                }
            }
            .environment(userPreferences)
            .environment(notificationManager)
            .task {
                await notificationManager.requestPermission()
                notificationManager.scheduleAllNotifications()
                BackgroundTaskManager.shared.scheduleNextRefresh()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    notificationManager.scheduleAllNotifications()
                }
            }
        }
    }
}
