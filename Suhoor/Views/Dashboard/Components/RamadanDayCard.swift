import SwiftUI

struct RamadanDayCard: View {
    let fastingDay: FastingDay
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Day \(fastingDay.dayNumber) of \(fastingDay.totalDays)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    
                    Text(fastingDay.hijriDate)
                        .font(.subheadline)
                        .foregroundStyle(Color.suhoorGold)
                    +
                    Text("  •  ")
                        .font(.subheadline)
                        .foregroundStyle(Color.suhoorTextSecondary)
                    +
                    Text(fastingDay.gregorianDate, format: .dateTime.month().day().year())
                        .font(.subheadline)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "moon.fill")
                    .font(.title2)
                    .foregroundStyle(Color.suhoorGold.opacity(0.3))
            }
            
            // Month progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.suhoorSurface)
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color.suhoorGold.opacity(0.6), Color.suhoorGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * fastingDay.monthProgress, height: 6)
                }
            }
            .frame(height: 6)
            
            Text(fastingDay.ashra.rawValue)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.suhoorAmber)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.suhoorAmber.opacity(0.12), in: Capsule())
        }
        .padding(16)
        .background(Color.suhoorSurface, in: RoundedRectangle(cornerRadius: 16))
    }
}
