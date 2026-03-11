import SwiftUI

struct DisplaySettingsView: View {
    @StateObject private var settings = AppSettings.shared

    var body: some View {
        List {
            Section {
                Picker("Time Format", selection: $settings.use24HourFormat) {
                    Text("12-Hour").tag(false)
                    Text("24-Hour").tag(true)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Time Format")
            }
            .listRowBackground(Color.suhoorSurface)

            Section {
                Picker("Language", selection: $settings.appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Language")
            }
            .listRowBackground(Color.suhoorSurface)

            Section {
                ForEach(AppColorTheme.allCases) { theme in
                    Button {
                        settings.colorTheme = theme
                    } label: {
                        HStack {
                            Circle()
                                .fill(theme.previewColor)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().stroke(Color.suhoorGold, lineWidth: 2)
                                        .opacity(settings.colorTheme == theme ? 1 : 0)
                                )
                            Text(theme.displayName)
                                .foregroundStyle(.suhoorTextPrimary)
                            Spacer()
                            if settings.colorTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.suhoorGold)
                            }
                        }
                    }
                }
            } header: {
                Text("Color Theme")
            }
            .listRowBackground(Color.suhoorSurface)

            Section {
                Toggle(isOn: $settings.hapticFeedbackEnabled) {
                    Label("Haptic Feedback", systemImage: "hand.tap")
                }
            } header: {
                Text("Feedback")
            }
            .listRowBackground(Color.suhoorSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.suhoorIndigo)
        .foregroundStyle(.suhoorTextPrimary)
        .navigationTitle("Display")
    }
}

#Preview {
    NavigationStack {
        DisplaySettingsView()
    }
}
