import SwiftUI

struct RamadanScorecardView: View {
    let dataManager: DataManager
    let ramadanYear: Int

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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ramadan Scorecard")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            // Main rings row
            HStack(spacing: 20) {
                RingChartView(
                    progress: Double(fastsCompleted) / 30.0,
                    lineWidth: 10,
                    gradient: [.suhoorGold, .suhoorAmber],
                    label: "Fasts",
                    value: "\(fastsCompleted)/30"
                )
                .frame(width: 100, height: 100)

                RingChartView(
                    progress: Double(juzCompleted) / 30.0,
                    lineWidth: 10,
                    gradient: [.suhoorSuccess, Color.green.opacity(0.6)],
                    label: "Quran",
                    value: "\(juzCompleted)/30"
                )
                .frame(width: 100, height: 100)

                RingChartView(
                    progress: min(Double(totalDeeds) / 150.0, 1.0),
                    lineWidth: 10,
                    gradient: [.purple, .pink],
                    label: "Deeds",
                    value: "\(totalDeeds)"
                )
                .frame(width: 100, height: 100)
            }
            .frame(maxWidth: .infinity)

            // Stats row
            HStack(spacing: 0) {
                StatPill(icon: "flame.fill", value: "\(longestStreak)", label: "Streak")
                Spacer()
                StatPill(icon: "checkmark.circle.fill", value: "\(totalDeeds)", label: "Deeds Done")
                Spacer()
                StatPill(icon: "book.fill", value: "\(juzCompleted)", label: "Juz Read")
            }
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct StatPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color.suhoorGold)
                Text(value)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.suhoorTextPrimary)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.suhoorTextSecondary)
        }
    }
}
