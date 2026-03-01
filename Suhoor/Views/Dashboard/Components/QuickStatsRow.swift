import SwiftUI

struct QuickStatsRow: View {
    let fastsCompleted: Int
    let streak: Int
    let quranJuz: Int
    let deedsToday: Int
    
    var body: some View {
        HStack(spacing: 12) {
            StatBubble(value: "\(fastsCompleted)", label: "Fasts", icon: "moon.fill")
            StatBubble(value: "\(streak) 🔥", label: "Streak", icon: nil)
            StatBubble(value: "Juz \(quranJuz)/30", label: "Quran", icon: nil)
            StatBubble(value: "\(deedsToday)", label: "Deeds", icon: "heart.fill")
        }
    }
}

private struct StatBubble: View {
    let value: String
    let label: String
    let icon: String?
    
    var body: some View {
        VStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(Color.suhoorGold.opacity(0.6))
            }
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.suhoorTextPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.suhoorTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.suhoorSurface, in: RoundedRectangle(cornerRadius: 12))
    }
}
