import SwiftUI

struct YearComparisonView: View {
    let dataManager: DataManager
    let currentYear: Int

    private var previousYear: Int { currentYear - 1 }
    private var hasPreviousData: Bool {
        !dataManager.fastingRecords(forRamadanYear: previousYear).isEmpty
    }

    var body: some View {
        if hasPreviousData {
            let current = dataManager.summary(forRamadanYear: currentYear)
            let previous = dataManager.summary(forRamadanYear: previousYear)

            VStack(alignment: .leading, spacing: 12) {
                Text("Year over Year")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.suhoorTextPrimary)

                HStack(spacing: 0) {
                    Text("")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(String(previousYear))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.suhoorTextSecondary)
                        .frame(width: 60)
                    Text("\(String(currentYear))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.suhoorGold)
                        .frame(width: 60)
                }

                ComparisonRow(label: "Fasts", previous: previous.totalFasted, current: current.totalFasted)
                ComparisonRow(label: "Quran (Juz)", previous: previous.totalPagesRead / 20, current: current.totalPagesRead / 20)
                ComparisonRow(label: "Deeds", previous: previous.totalDeedsCompleted, current: current.totalDeedsCompleted)
                ComparisonRow(label: "Streak", previous: previous.longestStreak, current: current.longestStreak)
            }
            .padding(20)
            .background(Color.suhoorNavy)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

private struct ComparisonRow: View {
    let label: String
    let previous: Int
    let current: Int

    private var diff: Int { current - previous }
    private var diffColor: Color {
        diff > 0 ? .suhoorSuccess : diff < 0 ? .suhoorWarning : .suhoorTextSecondary
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(previous)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(Color.suhoorTextSecondary)
                .frame(width: 60)

            HStack(spacing: 2) {
                Text("\(current)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Color.suhoorGold)
                if diff != 0 {
                    Text(diff > 0 ? "↑" : "↓")
                        .font(.caption2)
                        .foregroundStyle(diffColor)
                }
            }
            .frame(width: 60)
        }
        .padding(.vertical, 2)
    }
}
