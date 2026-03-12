import SwiftUI

struct FastingStreakView: View {
    let dataManager: DataManager
    let ramadanYear: Int

    private var currentStreak: Int {
        dataManager.currentStreak(ramadanYear: ramadanYear)
    }

    private var longestStreak: Int {
        dataManager.longestStreak(ramadanYear: ramadanYear)
    }

    private var milestoneMessage: String? {
        switch currentStreak {
        case 7: return "🎉 One week strong!"
        case 15: return "🎊 Halfway there!"
        case 21: return "💪 Three weeks!"
        case 30: return "🏆 Complete Ramadan!"
        default: return nil
        }
    }

    private var records: [FastingRecord] {
        dataManager.fastingRecords(forRamadanYear: ramadanYear)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Large streak counter
            VStack(spacing: 4) {
                Text("🔥 \(currentStreak) day streak")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.suhoorGold)

                if let msg = milestoneMessage {
                    Text(msg)
                        .font(.subheadline)
                        .foregroundStyle(Color.suhoorAmber)
                }

                if longestStreak > currentStreak {
                    Text("Best: \(longestStreak) days")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }

            // Visual streak timeline
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(records, id: \.dayNumber) { record in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(record.status == .fasted ? Color.suhoorSuccess :
                                      record.status == .missed ? Color.red :
                                      Color.suhoorWarning)
                                .frame(width: 8, height: record.status == .fasted ? 28 : 14)

                            Text("\(record.dayNumber)")
                                .font(.system(size: 7))
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
