import SwiftUI

@main
struct SuhoorApp: App {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var store = StoreService.shared

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var userPreferences = UserPreferences.shared
    @State private var notificationManager = NotificationManager.shared

    /// Track scene phase to reschedule notifications when app becomes active.
    @Environment(\.scenePhase) private var scenePhase

    init() {
        BackgroundTaskManager.shared.registerBackgroundTask()

        #if DEBUG
        if ScreenshotSampleData.isScreenshotMode {
            ScreenshotSampleData.populate(context: DataManager.shared.modelContext)
            // Skip onboarding in screenshot mode
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .environmentObject(store)
                        .preferredColorScheme(settings.appearanceMode.colorScheme)
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
