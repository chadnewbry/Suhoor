import SwiftUI

struct CountdownArcView: View {
    let progress: Double
    let label: String
    let hours: String
    let minutes: String
    let seconds: String
    var isNightMode: Bool = false

    @State private var animatedProgress: Double = 0

    private var accentColor: Color {
        isNightMode ? Color.suhoorMoonlight : Color.suhoorGold
    }

    private var gradientColors: [Color] {
        if isNightMode {
            let cool = Color(red: 0.15, green: 0.25, blue: 0.55)
            let moonlight = Color.suhoorMoonlight
            return [cool, moonlight.opacity(0.4 + progress * 0.6), moonlight]
        }
        let gold = Color.suhoorGold
        let blue = Color(red: 0.15, green: 0.20, blue: 0.55)
        return [blue, gold.opacity(0.3 + progress * 0.7), gold]
    }

    var body: some View {
        ZStack {
            // Background arc
            Circle()
                .stroke(Color.suhoorSurface, lineWidth: 12)
                .frame(width: 260, height: 260)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(-90))

            // Glow at tip
            Circle()
                .fill(accentColor.opacity(0.4))
                .frame(width: 20, height: 20)
                .blur(radius: 8)
                .offset(y: -130)
                .rotationEffect(.degrees(animatedProgress * 360))
                .opacity(animatedProgress > 0.01 ? 1 : 0)

            // Center content
            VStack(spacing: 8) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.suhoorTextSecondary)

                HStack(spacing: 4) {
                    TimeUnit(value: hours, accentColor: accentColor)
                    Text(":")
                        .font(.system(size: 40, weight: .thin, design: .rounded))
                        .foregroundStyle(accentColor.opacity(0.6))
                    TimeUnit(value: minutes, accentColor: accentColor)
                    if !seconds.isEmpty {
                        Text(":")
                            .font(.system(size: 40, weight: .thin, design: .rounded))
                            .foregroundStyle(accentColor.opacity(0.6))
                        TimeUnit(value: seconds, accentColor: accentColor)
                    }
                }

                Image(systemName: isNightMode ? "moon.stars.fill" : "moon.stars.fill")
                    .font(.caption)
                    .foregroundStyle(accentColor.opacity(0.4))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.linear(duration: 1)) {
                animatedProgress = newValue
            }
        }
    }
}

private struct TimeUnit: View {
    let value: String
    var accentColor: Color = .suhoorGold

    var body: some View {
        Text(value)
            .font(.system(size: 44, weight: .ultraLight, design: .rounded))
            .foregroundStyle(Color.suhoorTextPrimary)
            .monospacedDigit()
            .contentTransition(.numericText())
    }
}
