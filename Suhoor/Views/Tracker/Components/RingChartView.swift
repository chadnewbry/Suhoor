import SwiftUI

struct RingChartView: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: [Color]
    let label: String
    let value: String

    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        gradient: [Color] = [.suhoorGold, .suhoorAmber],
        label: String = "",
        value: String = ""
    ) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.gradient = gradient
        self.label = label
        self.value = value
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.suhoorSurface, lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradient),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)

            // Center text
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.suhoorTextPrimary)
                if !label.isEmpty {
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }
        }
    }
}

#Preview {
    RingChartView(progress: 0.7, label: "Fasts", value: "21/30")
        .frame(width: 100, height: 100)
        .padding()
        .background(Color.suhoorIndigo)
}
