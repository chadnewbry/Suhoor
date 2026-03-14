import SwiftUI

struct HydrationTrackerView: View {
    @ObservedObject var hydrationService: HydrationService
    
    private var entry: SimpleHydrationEntry { hydrationService.todayEntry }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hydration")
                        .font(.headline)
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Text(hydrationService.isHydrationWindowActive ? "Drink up!" : "Fasting hours")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
                Spacer()
                Text("💧")
                    .font(.title2)
            }
            
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.suhoorDivider, lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: entry.glasses)
                
                VStack(spacing: 4) {
                    Text("\(entry.glasses)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Text("of \(entry.target) glasses")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }
            .frame(width: 140, height: 140)
            
            // Add glass button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    hydrationService.logGlass()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Log Glass")
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(hydrationService.isHydrationWindowActive
                              ? Color.blue.opacity(0.8)
                              : Color.gray.opacity(0.4))
                )
            }
            .disabled(!hydrationService.isHydrationWindowActive)
            .accessibilityIdentifier("logGlassButton")
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.suhoorSurface)
        )
    }
}

#Preview {
    ZStack {
        Color.suhoorIndigo.ignoresSafeArea()
        HydrationTrackerView(hydrationService: .shared)
    }
}
