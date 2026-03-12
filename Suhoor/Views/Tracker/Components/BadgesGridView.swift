import SwiftUI

struct BadgesGridView: View {
    let dataManager: DataManager
    let ramadanYear: Int

    private var earnedBadgeTypes: Set<String> {
        Set(dataManager.badges(forRamadanYear: ramadanYear).map(\.badgeTypeRaw))
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Badges")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(BadgeType.allCases) { badgeType in
                    let isEarned = earnedBadgeTypes.contains(badgeType.rawValue)
                    let progress = dataManager.badgeProgress(badgeType, ramadanYear: ramadanYear)
                    BadgeCell(badgeType: badgeType, isEarned: isEarned, progress: progress)
                }
            }
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct BadgeCell: View {
    let badgeType: BadgeType
    let isEarned: Bool
    let progress: Double

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if !isEarned {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.suhoorGold.opacity(0.4), lineWidth: 3)
                        .rotationEffect(.degrees(-90))
                }

                Circle()
                    .fill(isEarned ? Color.suhoorGold.opacity(0.2) : Color.suhoorSurface)
                    .overlay(
                        Text(badgeType.emoji)
                            .font(.title2)
                            .grayscale(isEarned ? 0 : 1)
                            .opacity(isEarned ? 1 : 0.4)
                    )
            }
            .frame(width: 56, height: 56)

            Text(badgeType.displayName)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(isEarned ? Color.suhoorTextPrimary : Color.suhoorTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if !isEarned {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.suhoorGold.opacity(0.6))
            }
        }
    }
}
