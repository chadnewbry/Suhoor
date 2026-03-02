import SwiftUI

struct NextPrayerCard: View {
    let nextPrayer: PrayerTime?
    let allPrayers: [PrayerTime]
    let now: Date
    @Binding var expanded: Bool
    @State private var showPrayerTimes = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    if let prayer = nextPrayer {
                        Image(systemName: prayer.name.systemImage)
                            .font(.title2)
                            .foregroundStyle(Color.suhoorGold)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prayer.name.rawValue)
                                .font(.headline)
                                .foregroundStyle(Color.suhoorTextPrimary)
                            Text(prayer.formattedTime)
                                .font(.subheadline)
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                        
                        Spacer()
                        
                        Text(prayer.countdown(from: now))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.suhoorGold)
                        
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(Color.suhoorTextSecondary)
                    } else {
                        Text("All prayers completed")
                            .font(.subheadline)
                            .foregroundStyle(Color.suhoorTextSecondary)
                        Spacer()
                    }
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            
            // Expanded prayer list
            if expanded {
                Divider()
                    .background(Color.suhoorDivider)
                
                VStack(spacing: 0) {
                    ForEach(allPrayers) { prayer in
                        let isPast = prayer.time <= now
                        let isNext = prayer.id == nextPrayer?.id
                        
                        HStack(spacing: 14) {
                            Image(systemName: prayer.name.systemImage)
                                .font(.body)
                                .foregroundStyle(isNext ? Color.suhoorGold : Color.suhoorTextSecondary)
                                .frame(width: 30)
                            
                            Text(prayer.name.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(isNext ? Color.suhoorTextPrimary : Color.suhoorTextSecondary)
                            
                            Spacer()
                            
                            Text(prayer.formattedTime)
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(isNext ? Color.suhoorGold : Color.suhoorTextSecondary)
                            
                            if isPast {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.suhoorSuccess)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isNext ? Color.suhoorGold.opacity(0.06) : .clear)
                    }

                    Divider()
                        .background(Color.suhoorDivider)

                    Button {
                        showPrayerTimes = true
                    } label: {
                        HStack {
                            Text("View All Prayer Times")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color.suhoorGold)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(Color.suhoorGold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.suhoorSurface, in: RoundedRectangle(cornerRadius: 16))
        .navigationDestination(isPresented: $showPrayerTimes) {
            PrayerTimesView()
        }
    }
}
