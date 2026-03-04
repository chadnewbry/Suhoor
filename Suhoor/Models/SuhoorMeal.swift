import Foundation

struct SuhoorMeal: Codable, Identifiable {
    let day: Int
    let name: String
    let description: String

    var id: Int { day }
}
