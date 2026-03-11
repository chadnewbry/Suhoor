import SwiftUI

@main
struct SuhoorApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var store = StoreService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(notificationManager)
                .environmentObject(store)
                .task {
                    await notificationManager.setup()
                    await store.loadProducts()
                    await store.refreshEntitlements()
                }
        }
    }
}
