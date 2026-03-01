import SwiftData
import SwiftUI

@main
struct SuhoorApp: App {
    let container = ModelContainer.suhoor
    let settings = UserSettings.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(settings)
        }
        .modelContainer(container)
    }
}
