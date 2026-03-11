import Foundation

final class DuaService: ObservableObject {
    static let shared = DuaService()

    @Published private(set) var collection: DuaCollection

    private init() {
        self.collection = DuaCollection(duas: [])
        loadDuas()
    }

    private func loadDuas() {
        guard let url = Bundle.main.url(forResource: "duas", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode(DuaCollection.self, from: data) else {
            return
        }
        collection = loaded
    }

    func duas(for category: DuaCategory) -> [Dua] {
        collection.duas(for: category)
    }

    func allCategories() -> [DuaCategory] {
        collection.categories
    }

    /// Returns contextually relevant duas based on current time of day
    func suggestedDuas() -> [Dua] {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 5 {
            return duas(for: .sehri)
        } else if hour >= 17 && hour <= 20 {
            return duas(for: .iftar)
        } else {
            // Return ashra-specific based on day of Ramadan
            let islamic = Calendar(identifier: .islamicUmmAlQura)
            let day = islamic.dateComponents([.day], from: Date()).day ?? 1
            if day <= 10 {
                return duas(for: .firstAshra)
            } else if day <= 20 {
                return duas(for: .secondAshra)
            } else {
                return duas(for: .thirdAshra)
            }
        }
    }
}
