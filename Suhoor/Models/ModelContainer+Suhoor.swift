import Foundation
import SwiftData

extension ModelContainer {
    static var suhoor: ModelContainer {
        let schema = Schema([
            FastingRecord.self,
            QuranProgress.self,
            DeedEntry.self,
            HydrationEntry.self,
            MakeupFast.self,
            Badge.self,
        ])

        let configuration = ModelConfiguration(
            "Suhoor",
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create Suhoor ModelContainer: \(error)")
        }
    }

    /// In-memory container for previews and testing.
    static var preview: ModelContainer {
        let schema = Schema([
            FastingRecord.self,
            QuranProgress.self,
            DeedEntry.self,
            HydrationEntry.self,
            MakeupFast.self,
            Badge.self,
        ])

        let configuration = ModelConfiguration(
            "SuhoorPreview",
            schema: schema,
            isStoredInMemoryOnly: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }
}
