import SwiftUI

struct CalculationMethodStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)

            Image(systemName: "sun.and.horizon.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.suhoorGold)

            Text("Calculation Method")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            Text("Choose the method used in your region\nfor calculating prayer times.")
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(CalculationMethod.allCases) { method in
                        Button {
                            vm.calculationMethod = method
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(method.rawValue)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.suhoorTextPrimary)
                                    Text(method.shortDescription)
                                        .font(.caption)
                                        .foregroundStyle(Color.suhoorTextSecondary)
                                }
                                Spacer()
                                if vm.calculationMethod == method {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.suhoorGold)
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(vm.calculationMethod == method ? Color.suhoorGold.opacity(0.1) : Color.suhoorSurface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(vm.calculationMethod == method ? Color.suhoorGold.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            OnboardingButton(title: "Continue") {
                vm.advance()
            }

            Spacer().frame(height: 20)
        }
    }
}
