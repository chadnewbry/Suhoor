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
                            Text(category.subtitle)
                                .font(.caption)
                                .foregroundStyle(Color.suhoorTextSecondary)
                            Text("\(duaService.duas(for: category).count) duas")
                                .font(.caption2)
                                .foregroundStyle(Color.suhoorTextSecondary.opacity(0.7))
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
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text(dua.arabicText)
                .font(.system(size: 26, weight: .regular, design: .serif))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.suhoorTextPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
                .lineSpacing(8)

            Text(dua.transliteration)
                .font(.subheadline)
                .italic()
                .foregroundStyle(Color.suhoorGold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(dua.englishTranslation)
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                if let ref = dua.reference {
                    Text("— \(ref)")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary.opacity(0.7))
                }

                Spacer()

                Button {
                    shareImage = renderDuaImage(dua)
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(Color.suhoorGold)
                }
            }
        }
        .padding()
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }

    // MARK: - Render Dua as Image

    private func renderDuaImage(_ dua: Dua) -> UIImage {
        let renderer = ImageRenderer(content: DuaShareCard(dua: dua))
        renderer.scale = 3.0
        return renderer.uiImage ?? UIImage()
    }
}

// MARK: - Dua Share Card (for image rendering)

struct DuaShareCard: View {
    let dua: Dua

    var body: some View {
        VStack(spacing: 20) {
            // Decorative header
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.suhoorGold)
                Text("☪")
                    .font(.title)
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.suhoorGold)
            }

            Text(dua.arabicText)
                .font(.system(size: 28, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .lineSpacing(10)

            Rectangle()
                .fill(Color.suhoorGold)
                .frame(width: 60, height: 2)

            Text(dua.transliteration)
                .font(.system(size: 14))
                .italic()
                .foregroundStyle(Color.suhoorGold)
                .multilineTextAlignment(.center)

            Text(dua.englishTranslation)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)

            if let ref = dua.reference {
                Text("— \(ref)")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text("Suhoor — Ramadan Companion")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.suhoorGold.opacity(0.6))
        }
        .padding(32)
        .frame(width: 400)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.05, blue: 0.18),
                    Color(red: 0.10, green: 0.08, blue: 0.25),
                    Color(red: 0.06, green: 0.05, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
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
