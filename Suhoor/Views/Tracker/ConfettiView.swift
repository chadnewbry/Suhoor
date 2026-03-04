import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let age = now - particle.startTime
                    guard age < 3 else { continue }
                    
                    let x = particle.x * size.width + sin(age * particle.wobble) * 30
                    let y = particle.initialY + age * particle.speed * size.height / 3
                    let opacity = max(0, 1 - age / 3)
                    
                    context.opacity = opacity
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8)),
                        with: .color(particle.color)
                    )
                }
            }
        }
        .onAppear {
            let now = Date.timeIntervalSinceReferenceDate
            particles = (0..<80).map { _ in
                ConfettiParticle(
                    x: Double.random(in: 0...1),
                    initialY: Double.random(in: -50...0),
                    speed: Double.random(in: 0.3...1),
                    wobble: Double.random(in: 2...6),
                    color: [Color.suhoorGold, .suhoorAmber, .suhoorSuccess, .pink, .orange, .yellow].randomElement()!,
                    startTime: now + Double.random(in: 0...0.5)
                )
            }
        }
    }
}

private struct ConfettiParticle {
    let x: Double
    let initialY: Double
    let speed: Double
    let wobble: Double
    let color: Color
    let startTime: TimeInterval
}

#Preview {
    ConfettiView()
        .background(Color.suhoorIndigo)
        .preferredColorScheme(.dark)
}
