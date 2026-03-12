import SwiftUI

struct MadhhabStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "building.columns.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.suhoorGold)

            Text("Madhhab")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            Text("This affects the Asr prayer time calculation.")
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                ForEach(Madhhab.allCases) { madhhab in
                    Button {
                        vm.madhhab = madhhab
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(madhhab.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(Color.suhoorTextPrimary)
                                Text(madhhab == .hanafi
                                     ? "Shadow length is twice the object — later Asr"
                                     : "Shadow length equals the object — earlier Asr")
                                    .font(.caption)
                                    .foregroundStyle(Color.suhoorTextSecondary)
                            }
                            Spacer()
                            if vm.madhhab == madhhab {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.suhoorGold)
                                    .font(.title3)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(vm.madhhab == madhhab ? Color.suhoorGold.opacity(0.1) : Color.suhoorSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(vm.madhhab == madhhab ? Color.suhoorGold.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            OnboardingButton(title: "Continue") {
                vm.advance()
            }

            Spacer().frame(height: 20)
        }
    }
}
