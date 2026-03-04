import SwiftUI

struct AshraCard: View {
    let ashra: Ashra
    let completion: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ashra \(ashra.rawValue): \(ashra.name)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Text("Days \(ashra.dayRange.lowerBound)–\(ashra.dayRange.upperBound)")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
                Spacer()
                Text("\(Int(completion * 100))%")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.suhoorGold)
            }
            
            ProgressView(value: completion)
                .tint(Color.suhoorGold)
            
            Text(ashra.dua)
                .font(.caption)
                .foregroundStyle(Color.suhoorAmber)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Text(ashra.duaTranslation)
                .font(.caption2)
                .foregroundStyle(Color.suhoorTextSecondary)
                .italic()
        }
        .padding()
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AshraCard(ashra: .mercy, completion: 0.7)
        .padding()
        .background(Color.suhoorIndigo)
        .preferredColorScheme(.dark)
}
