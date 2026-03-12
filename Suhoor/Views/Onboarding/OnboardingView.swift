import SwiftUI

struct OnboardingView: View {
    @State private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.suhoorIndigo, Color.suhoorIndigo.opacity(0.85), Color(red: 0.05, green: 0.04, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative stars
            StarsBackground()

            VStack(spacing: 0) {
                // Back button area
                HStack {
                    if vm.currentPage != .welcome {
                        Button {
                            vm.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .frame(height: 44)

                // Content
                TabView(selection: $vm.currentPage) {
                    WelcomeStepView(vm: vm)
                        .tag(OnboardingViewModel.Page.welcome)

                    LocationStepView(vm: vm)
                        .tag(OnboardingViewModel.Page.location)

                    CalculationMethodStepView(vm: vm)
                        .tag(OnboardingViewModel.Page.calculationMethod)

                    MadhhabStepView(vm: vm)
                        .tag(OnboardingViewModel.Page.madhhab)

                    NotificationsStepView(vm: vm)
                        .tag(OnboardingViewModel.Page.notifications)

                    LanguageStepView(vm: vm)
                        .tag(OnboardingViewModel.Page.language)

                    MenstrualModeStepView(vm: vm)
                        .tag(OnboardingViewModel.Page.menstrualMode)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: vm.currentPage)

                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<vm.totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == vm.currentIndex ? Color.suhoorGold : Color.suhoorTextSecondary.opacity(0.3))
                            .frame(width: index == vm.currentIndex ? 10 : 7,
                                   height: index == vm.currentIndex ? 10 : 7)
                            .animation(.easeInOut(duration: 0.25), value: vm.currentIndex)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Decorative Stars

private struct StarsBackground: View {
    var body: some View {
        Canvas { context, size in
            for i in 0..<60 {
                let seed = Double(i)
                let x = (sin(seed * 12.9898 + 78.233) * 43758.5453).truncatingRemainder(dividingBy: 1.0)
                let y = (sin(seed * 45.164 + 12.989) * 43758.5453).truncatingRemainder(dividingBy: 1.0)
                let radius = (sin(seed * 93.9) * 43758.5453).truncatingRemainder(dividingBy: 1.0) * 1.5 + 0.5
                let opacity = abs((sin(seed * 17.3) * 43758.5453).truncatingRemainder(dividingBy: 1.0)) * 0.4 + 0.1

                let point = CGPoint(x: abs(x) * size.width, y: abs(y) * size.height)
                context.opacity = opacity
                context.fill(
                    Path(ellipseIn: CGRect(x: point.x, y: point.y, width: radius * 2, height: radius * 2)),
                    with: .color(.white)
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Shared Components

struct OnboardingButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.suhoorIndigo)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnabled ? Color.suhoorGold : Color.suhoorGold.opacity(0.3))
                )
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 32)
    }
}

struct OnboardingSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.suhoorTextSecondary)
        }
    }
}

#Preview {
    OnboardingView()
}
