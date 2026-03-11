import SwiftUI

struct DuasView: View {
    @StateObject private var duaService = DuaService.shared
    @State private var selectedCategory: DuaCategory?

    var body: some View {
        ZStack {
            Color.suhoorIndigo.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Suggested Duas
                    if !duaService.suggestedDuas().isEmpty {
                        suggestedSection
                    }

                    // Categories
                    categoriesSection
                }
                .padding()
            }
        }
        .navigationTitle("Duas")
        .sheet(item: $selectedCategory) { category in
            DuaCategorySheet(category: category, duas: duaService.duas(for: category))
        }
    }

    private var suggestedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested Now")
                .font(.headline)
                .foregroundStyle(Color.suhoorTextPrimary)

            ForEach(duaService.suggestedDuas()) { dua in
                DuaCard(dua: dua)
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .foregroundStyle(Color.suhoorTextPrimary)

            ForEach(DuaCategory.allCases) { category in
                Button {
                    selectedCategory = category
                } label: {
                    HStack {
                        Text(category.emoji)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(category.rawValue)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.suhoorTextPrimary)
                            Text("\(duaService.duas(for: category).count) duas")
                                .font(.caption)
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.suhoorTextSecondary)
                    }
                    .padding()
                    .background(Color.suhoorSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

// MARK: - Dua Card

struct DuaCard: View {
    let dua: Dua

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text(dua.arabicText)
                .font(.title3)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.suhoorTextPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)

            Text(dua.transliteration)
                .font(.subheadline)
                .italic()
                .foregroundStyle(Color.suhoorGold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(dua.englishTranslation)
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let ref = dua.reference {
                Text("— \(ref)")
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Category Sheet

private struct DuaCategorySheet: View {
    let category: DuaCategory
    let duas: [Dua]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(duas) { dua in
                            DuaCard(dua: dua)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("\(category.emoji) \(category.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        DuasView()
    }
}
