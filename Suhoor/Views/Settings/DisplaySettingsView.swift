import SwiftUI

struct DisplaySettingsView: View {
    @StateObject private var settings = AppSettings.shared
    @ObservedObject private var store = StoreService.shared
    @State private var showPaywall = false

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
                    let isDefault = theme == .midnightBlue
                    let isLocked = !isDefault && !store.isPro

                    Button {
                        if isLocked {
                            showPaywall = true
                        } else {
                            settings.colorTheme = theme
                        }
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
                                .foregroundStyle(Color.suhoorTextPrimary)

                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color.suhoorGold)
                            }

                            Spacer()
                            if settings.colorTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.suhoorGold)
                            }
                        }
                    }
                }
            } header: {
                Text("Color Theme")
            } footer: {
                if !store.isPro {
                    Text("Upgrade to Pro to unlock all themes")
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
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
        .foregroundStyle(Color.suhoorTextPrimary)
        .navigationTitle("Display")
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    NavigationStack {
        DisplaySettingsView()
    }
}
