import SwiftUI
import SwiftData

@main
struct SuhoorApp: App {
    let modelContainer: ModelContainer = .suhoor

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
