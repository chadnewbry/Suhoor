import SwiftUI

struct ShareableSummaryView: View {
    let dataManager: DataManager
    let ramadanYear: Int
    @State private var showShareSheet = false
    @State private var renderedImage: UIImage?

    private var fastsCompleted: Int {
        dataManager.fastingRecords(forRamadanYear: ramadanYear)
            .filter { $0.status == .fasted }.count
    }

    private var juzCompleted: Int {
        dataManager.completedJuzCount(ramadanYear: ramadanYear)
    }

    private var totalDeeds: Int {
        dataManager.totalDeedsCompleted(ramadanYear: ramadanYear)
    }

    private var longestStreak: Int {
        dataManager.longestStreak(ramadanYear: ramadanYear)
    }

    private var earnedBadgeCount: Int {
        dataManager.badges(forRamadanYear: ramadanYear).count
    }

    var body: some View {
        Button {
            renderAndShare()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share Ramadan Summary")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Color.suhoorIndigo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.suhoorGold)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheet(items: [image])
            }
        }
    }

    @MainActor
    private func renderAndShare() {
        let card = ShareCardContent(
            fastsCompleted: fastsCompleted,
            juzCompleted: juzCompleted,
            totalDeeds: totalDeeds,
            longestStreak: longestStreak,
            earnedBadges: earnedBadgeCount,
            ramadanYear: ramadanYear
        )

        let renderer = ImageRenderer(content: card.frame(width: 390))
        renderer.scale = 3
        if let image = renderer.uiImage {
            renderedImage = image
            showShareSheet = true
        }
    }
}

// The shareable card content (rendered to image)
private struct ShareCardContent: View {
    let fastsCompleted: Int
    let juzCompleted: Int
    let totalDeeds: Int
    let longestStreak: Int
    let earnedBadges: Int
    let ramadanYear: Int

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("🌙")
                    .font(.system(size: 48))
                Text("My Ramadan \(String(ramadanYear))")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }

            // Stats grid
            HStack(spacing: 20) {
                ShareStat(emoji: "🕌", value: "\(fastsCompleted)/30", label: "Fasts")
                ShareStat(emoji: "📖", value: "\(juzCompleted)/30", label: "Juz")
                ShareStat(emoji: "✅", value: "\(totalDeeds)", label: "Deeds")
            }

            HStack(spacing: 20) {
                ShareStat(emoji: "🔥", value: "\(longestStreak)", label: "Best Streak")
                ShareStat(emoji: "🏅", value: "\(earnedBadges)", label: "Badges")
            }

            // Footer
            Text("Tracked with Suhoor")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(32)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.07, blue: 0.20),
                    Color(red: 0.15, green: 0.10, blue: 0.30),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private struct ShareStat: View {
    let emoji: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title2)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// UIKit share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
