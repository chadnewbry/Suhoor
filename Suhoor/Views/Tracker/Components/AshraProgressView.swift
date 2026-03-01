import SwiftUI

struct AshraProgressView: View {
    let dataManager: DataManager
    let ramadanYear: Int

    private var records: [FastingRecord] {
        dataManager.fastingRecords(forRamadanYear: ramadanYear)
    }

    private func fastedCount(in range: ClosedRange<Int>) -> Int {
        records.filter { range.contains($0.dayNumber) && $0.status == .fasted }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ashra Progress")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            HStack(spacing: 16) {
                AshraRing(
                    title: "Mercy",
                    arabic: "رحمة",
                    range: "Days 1-10",
                    progress: Double(fastedCount(in: 1...10)) / 10.0,
                    gradient: [.suhoorGold, .suhoorAmber],
                    dua: "O Allah, have mercy on me"
                )
                AshraRing(
                    title: "Forgiveness",
                    arabic: "مغفرة",
                    range: "Days 11-20",
                    progress: Double(fastedCount(in: 11...20)) / 10.0,
                    gradient: [.suhoorSuccess, .green.opacity(0.6)],
                    dua: "O Allah, forgive me"
                )
                AshraRing(
                    title: "Freedom",
                    arabic: "نجاة",
                    range: "Days 21-30",
                    progress: Double(fastedCount(in: 21...30)) / 10.0,
                    gradient: [.purple, .pink],
                    dua: "O Allah, protect me from the Fire"
                )
            }
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct AshraRing: View {
    let title: String
    let arabic: String
    let range: String
    let progress: Double
    let gradient: [Color]
    let dua: String

    var body: some View {
        VStack(spacing: 8) {
            RingChartView(
                progress: progress,
                lineWidth: 6,
                gradient: gradient,
                label: "",
                value: "\(Int(progress * 10))/10"
            )
            .frame(width: 70, height: 70)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.suhoorTextPrimary)

            Text(arabic)
                .font(.caption2)
                .foregroundStyle(Color.suhoorGold)

            Text(range)
                .font(.system(size: 8))
                .foregroundStyle(Color.suhoorTextSecondary)

            Text(dua)
                .font(.system(size: 7))
                .foregroundStyle(Color.suhoorTextSecondary)
                .multilineTextAlignment(.center)
                .italic()
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}
