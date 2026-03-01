import SwiftUI

struct DeedOfTheDayCard: View {
    let deed: DeedOfTheDay
    
    var body: some View {
        HStack(spacing: 14) {
            Text(deed.emoji)
                .font(.largeTitle)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Deed of the Day")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.suhoorGold)
                
                Text(deed.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.suhoorTextPrimary)
                
                Text(deed.description)
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
                    .lineLimit(2)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.suhoorGold.opacity(0.08), Color.suhoorSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}
