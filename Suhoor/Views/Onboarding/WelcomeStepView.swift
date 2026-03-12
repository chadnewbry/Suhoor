import SwiftUI

struct WelcomeStepView: View {
    let vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Moon & Star icon
            ZStack {
                Circle()
                    .fill(Color.suhoorGold.opacity(0.1))
                    .frame(width: 160, height: 160)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.suhoorGold, .suhoorAmber],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Text("Suhoor")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.suhoorTextPrimary)

                Text("Ramadan Companion")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.suhoorGold)

                Text("Your complete guide through the blessed month.\nPrayer times, fasting tracker, Quran progress & more.")
                    .font(.subheadline)
                    .foregroundStyle(Color.suhoorTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }

            Spacer()

            OnboardingButton(title: "Get Started") {
                vm.advance()
            }

            Spacer()
                .frame(height: 20)
        }
    }
}
