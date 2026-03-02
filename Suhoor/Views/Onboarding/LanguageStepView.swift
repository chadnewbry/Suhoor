import SwiftUI

struct LanguageStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            Image(systemName: "globe")
                .font(.system(size: 48))
                .foregroundStyle(Color.suhoorGold)

            Text("Language")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            Text("Choose your preferred language.")
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)

            VStack(spacing: 8) {
                ForEach(AppLanguage.allCases) { lang in
                    Button {
                        vm.language = lang
                    } label: {
                        HStack {
                            Text(lang.displayName)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.suhoorTextPrimary)

                            if lang.rawValue != lang.displayName {
                                Text("(\(lang.rawValue.uppercased()))")
                                    .font(.caption)
                                    .foregroundStyle(Color.suhoorTextSecondary)
                            }

                            Spacer()

                            if vm.language == lang {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.suhoorGold)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(vm.language == lang ? Color.suhoorGold.opacity(0.1) : Color.suhoorSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.language == lang ? Color.suhoorGold.opacity(0.4) : Color.clear, lineWidth: 1)
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
