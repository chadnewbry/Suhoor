import SwiftUI

struct SuhoorMealCardView: View {
    @State private var currentIndex = 0
    private let meals: [SuhoorMeal]
    
    init() {
        var allMeals = [SuhoorMeal.todaysMeal()]
        allMeals.append(contentsOf: SuhoorMeal.alternatives())
        self.meals = allMeals
    }
    
    private var currentMeal: SuhoorMeal { meals[currentIndex] }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentIndex == 0 ? "Today's Suhoor" : "Alternative")
                        .font(.headline)
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Text("Swipe for more options")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
                Spacer()
                Text(currentMeal.emoji)
                    .font(.largeTitle)
            }
            
            // Meal content
            TabView(selection: $currentIndex) {
                ForEach(Array(meals.enumerated()), id: \.element.id) { index, meal in
                    mealContent(meal)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 180)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.suhoorSurface)
        )
        .accessibilityIdentifier("suhoorMealCard")
    }
    
    @ViewBuilder
    private func mealContent(_ meal: SuhoorMeal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(meal.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.suhoorGold)
            
            Text(meal.description)
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .lineLimit(3)
            
            // Benefits
            HStack(spacing: 8) {
                ForEach(meal.benefits.prefix(3), id: \.self) { benefit in
                    Text(benefit)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.suhoorTextPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.suhoorGold.opacity(0.2))
                        )
                }
            }
            
            // Category badge
            Text(meal.category.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.suhoorAmber)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .strokeBorder(Color.suhoorAmber.opacity(0.3))
                )
        }
    }
}

#Preview {
    ZStack {
        Color.suhoorIndigo.ignoresSafeArea()
        SuhoorMealCardView()
            .padding()
    }
}
