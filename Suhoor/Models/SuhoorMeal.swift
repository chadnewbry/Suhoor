import Foundation

struct SuhoorMeal: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let emoji: String
    let ingredients: [String]
    let benefits: [String]
    let category: MealCategory
    
    enum MealCategory: String, Codable, CaseIterable {
        case protein = "Protein"
        case hydrating = "Hydrating"
        case energySustaining = "Energy Sustaining"
        case balanced = "Balanced"
    }
    
    static let bundledMeals: [SuhoorMeal] = [
        SuhoorMeal(id: UUID(), name: "Dates & Oatmeal Bowl", description: "Warm oatmeal topped with dates, honey, and a sprinkle of cinnamon. Slow-releasing carbs to sustain you through the fast.", emoji: "🥣", ingredients: ["Oats", "Dates", "Honey", "Cinnamon", "Milk"], benefits: ["Slow-release energy", "Rich in fiber", "Natural sweetness"], category: .energySustaining),
        SuhoorMeal(id: UUID(), name: "Egg & Avocado Toast", description: "Whole grain toast with mashed avocado and a boiled egg. Protein and healthy fats keep hunger at bay.", emoji: "🥑", ingredients: ["Whole grain bread", "Avocado", "Eggs", "Salt", "Pepper"], benefits: ["High protein", "Healthy fats", "Keeps you full"], category: .protein),
        SuhoorMeal(id: UUID(), name: "Banana Smoothie", description: "Blended banana with milk, dates, and a spoon of peanut butter. Hydrating and energy-packed.", emoji: "🍌", ingredients: ["Banana", "Milk", "Dates", "Peanut butter"], benefits: ["Hydrating", "Potassium-rich", "Quick to prepare"], category: .hydrating),
        SuhoorMeal(id: UUID(), name: "Yogurt & Fruit Parfait", description: "Creamy yogurt layered with fresh fruits, granola, and a drizzle of honey.", emoji: "🫐", ingredients: ["Yogurt", "Mixed berries", "Granola", "Honey"], benefits: ["Probiotics", "Hydrating fruits", "Sustained energy"], category: .balanced),
        SuhoorMeal(id: UUID(), name: "Cucumber & Cheese Wrap", description: "Light wrap with feta cheese, cucumber, tomato, and mint. Water-rich and satisfying.", emoji: "🫔", ingredients: ["Whole wheat wrap", "Feta cheese", "Cucumber", "Tomato", "Mint"], benefits: ["Water-rich vegetables", "Protein from cheese", "Light on stomach"], category: .hydrating),
        SuhoorMeal(id: UUID(), name: "Ful Medames", description: "Traditional fava bean stew with olive oil, lemon, and cumin. A suhoor staple across the Muslim world.", emoji: "🫘", ingredients: ["Fava beans", "Olive oil", "Lemon", "Cumin", "Garlic"], benefits: ["High protein", "Very filling", "Iron-rich"], category: .protein),
        SuhoorMeal(id: UUID(), name: "Overnight Chia Pudding", description: "Chia seeds soaked overnight in milk with dates and almonds. Prepare before sleep, eat at suhoor.", emoji: "🥛", ingredients: ["Chia seeds", "Milk", "Dates", "Almonds", "Vanilla"], benefits: ["Omega-3 fatty acids", "No cooking needed", "Hydrating"], category: .energySustaining),
        SuhoorMeal(id: UUID(), name: "Sweet Potato & Egg Plate", description: "Roasted sweet potato with scrambled eggs and a side of watermelon. Balanced and hydrating.", emoji: "🍠", ingredients: ["Sweet potato", "Eggs", "Watermelon", "Olive oil"], benefits: ["Complex carbs", "Protein", "Hydrating fruit"], category: .balanced),
        SuhoorMeal(id: UUID(), name: "Lentil Soup", description: "Warm red lentil soup with bread. Easy to digest, high in protein, and deeply comforting.", emoji: "🍲", ingredients: ["Red lentils", "Onion", "Carrot", "Cumin", "Bread"], benefits: ["Easy to digest", "High protein", "Warming"], category: .protein),
        SuhoorMeal(id: UUID(), name: "Watermelon & Halloumi", description: "Fresh watermelon cubes with grilled halloumi cheese and mint. Maximizes hydration.", emoji: "🍉", ingredients: ["Watermelon", "Halloumi", "Mint", "Olive oil"], benefits: ["92% water content", "Protein from cheese", "Refreshing"], category: .hydrating),
    ]
    
    /// Returns today's suggested meal (deterministic based on date)
    static func todaysMeal() -> SuhoorMeal {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return bundledMeals[dayOfYear % bundledMeals.count]
    }
    
    /// Returns alternative meals (excluding today's)
    static func alternatives() -> [SuhoorMeal] {
        let today = todaysMeal()
        return bundledMeals.filter { $0.id != today.id }
    }
}

#if DEBUG
extension SuhoorMeal: PreviewData {
    static var preview: SuhoorMeal { bundledMeals[0] }
    static var previewList: [SuhoorMeal] { Array(bundledMeals.prefix(5)) }
}
#endif
