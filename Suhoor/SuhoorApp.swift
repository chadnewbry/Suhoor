import SwiftData
import SwiftUI

@main
struct SuhoorApp: App {
    let container = ModelContainer.suhoor
    let settings = UserSettings.shared
    @StateObject private var store = StoreService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .environment(settings)
        }
        .modelContainer(container)
    }
}
