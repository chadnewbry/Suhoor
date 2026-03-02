import SwiftUI

struct MenstrualModeStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.suhoorGold)

            Text("Period Tracking")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            Text("Would you like to enable period tracking\nfor excused fasting days?")
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("This helps you keep track of makeup fasts\nand adjusts your Ramadan progress accordingly.")
                .font(.caption)
                .foregroundStyle(Color.suhoorTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(spacing: 12) {
                Button {
                    vm.menstrualModeEnabled = true
                } label: {
                    HStack {
                        Text("Yes, enable")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.suhoorTextPrimary)
                        Spacer()
                        if vm.menstrualModeEnabled {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.suhoorGold)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(vm.menstrualModeEnabled ? Color.suhoorGold.opacity(0.1) : Color.suhoorSurface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(vm.menstrualModeEnabled ? Color.suhoorGold.opacity(0.4) : Color.clear, lineWidth: 1)
                    )
                }

                Button {
                    vm.menstrualModeEnabled = false
                } label: {
                    HStack {
                        Text("No, thanks")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.suhoorTextPrimary)
                        Spacer()
                        if !vm.menstrualModeEnabled {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.suhoorGold)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(!vm.menstrualModeEnabled ? Color.suhoorGold.opacity(0.1) : Color.suhoorSurface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(!vm.menstrualModeEnabled ? Color.suhoorGold.opacity(0.4) : Color.clear, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            OnboardingButton(title: "Complete Setup") {
                vm.advance()
            }

            Text("You can always change this in Settings.")
                .font(.caption)
                .foregroundStyle(Color.suhoorTextSecondary)

            Spacer().frame(height: 20)
        }
    }
}
