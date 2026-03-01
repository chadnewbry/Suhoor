import SwiftUI

struct DailyVerseCard: View {
    let verse: QuranVerse
    @State private var showFull = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundStyle(Color.suhoorGold)
                Text("Daily Verse")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.suhoorTextSecondary)
                Spacer()
                
                ShareLink(item: "\(verse.translation)\n— \(verse.reference)") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }
            
            Text(verse.arabic)
                .font(.title3)
                .foregroundStyle(Color.suhoorTextPrimary)
                .multilineTextAlignment(.trailing)
                .lineLimit(showFull ? nil : 2)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
            
            Text(verse.translation)
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .lineLimit(showFull ? nil : 3)
            
            Text(verse.reference)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.suhoorGold.opacity(0.7))
            
            if !showFull {
                Button {
                    withAnimation { showFull = true }
                } label: {
                    Text("Read more")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.suhoorGold)
                }
            }
        }
        .padding(16)
        .background(Color.suhoorSurface, in: RoundedRectangle(cornerRadius: 16))
    }
}
