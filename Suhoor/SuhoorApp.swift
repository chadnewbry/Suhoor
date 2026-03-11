import SwiftUI

@main
struct SuhoorApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(notificationManager)
                .task {
                    await notificationManager.setup()
                }
        }
    }
}
