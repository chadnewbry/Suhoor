import SwiftUI
import CoreLocation

struct PrayerTimeSettingsView: View {
    @StateObject private var settings = AppSettings.shared
    @State private var detectedLocation: String = "Detecting..."

    var body: some View {
        List {
            // MARK: - Calculation Method
            Section {
                Picker("Method", selection: $settings.calculationMethod) {
                    ForEach(CalculationMethod.allCases) { method in
                        Text(method.displayName).tag(method)
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Calculation Method")
            } footer: {
                Text("Determines Fajr and Isha angles for prayer time calculation.")
            }
            .listRowBackground(Color.suhoorSurface)

            // MARK: - Madhhab
            Section {
                Picker("Madhhab", selection: $settings.madhhab) {
                    ForEach(Madhhab.allCases) { m in
                        Text(m.displayName).tag(m)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Madhhab (Juristic Method)")
            } footer: {
                Text("Affects Asr prayer time calculation. Hanafi uses a later Asr time.")
            }
            .listRowBackground(Color.suhoorSurface)

            // MARK: - Location
            Section {
                Toggle("Use Current Location", isOn: $settings.useCurrentLocation)

                if !settings.useCurrentLocation {
                    TextField("Location Name", text: $settings.manualLocationName)
                    HStack {
                        Text("Latitude")
                        Spacer()
                        TextField("0.0", value: $settings.manualLatitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    HStack {
                        Text("Longitude")
                        Spacer()
                        TextField("0.0", value: $settings.manualLongitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                } else {
                    HStack {
                        Text("Detected")
                        Spacer()
                        Text(detectedLocation)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Location")
            }
            .listRowBackground(Color.suhoorSurface)

            // MARK: - Manual Adjustments
            Section {
                ForEach(Prayer.allCases.filter(\.hasAzan)) { prayer in
                    Stepper(
                        "\(prayer.emoji) \(prayer.displayName): \(settings.adjustmentMinutes(for: prayer).formatted(.number.sign(strategy: .always()))) min",
                        value: Binding(
                            get: { settings.adjustmentMinutes(for: prayer) },
                            set: { settings.setAdjustment($0, for: prayer) }
                        ),
                        in: -30...30
                    )
                    .font(.subheadline)
                }
            } header: {
                Text("Manual Adjustments")
            } footer: {
                Text("Fine-tune individual prayer times by adding or subtracting minutes.")
            }
            .listRowBackground(Color.suhoorSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.suhoorIndigo)
        .foregroundStyle(.suhoorTextPrimary)
        .navigationTitle("Prayer Times")
    }
}

#Preview {
    NavigationStack {
        PrayerTimeSettingsView()
    }
}
