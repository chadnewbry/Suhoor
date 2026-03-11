import SwiftUI

@main
struct SuhoorApp: App {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var store = StoreService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(settings.appearanceMode.colorScheme)
        }
    }
}
