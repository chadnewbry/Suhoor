import SwiftUI
import SwiftData

@main
struct SuhoorApp: App {
    let modelContainer: ModelContainer = .suhoor
    let settings = UserSettings.shared
    @StateObject private var store = StoreService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
