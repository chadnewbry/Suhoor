import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        List {
            // MARK: - App Info
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.suhoorGold)
                        Text("Suhoor")
                            .font(.title2.bold())
                        Text("Your Ramadan Companion")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    Spacer()
                }
            }
            .listRowBackground(Color.suhoorSurface)

            // MARK: - Version
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(appVersion) (\(buildNumber))")
                        .foregroundStyle(.secondary)
                }
            }
            .listRowBackground(Color.suhoorSurface)

            // MARK: - Credits
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Developed by Chad Newbry LLC")
                        .font(.subheadline)
                    Text("Designed with ❤️ for the Muslim community worldwide.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Credits")
            }
            .listRowBackground(Color.suhoorSurface)

            // MARK: - Data Sources
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    dataSourceRow(
                        title: "Prayer Time Calculation",
                        detail: "Based on established astronomical algorithms used by ISNA, MWL, Egyptian General Authority, and other recognized Islamic organizations."
                    )
                    Divider().background(Color.suhoorDivider)
                    dataSourceRow(
                        title: "Qibla Direction",
                        detail: "Calculated using the great-circle bearing formula from the device's location to the Kaaba in Makkah."
                    )
                    Divider().background(Color.suhoorDivider)
                    dataSourceRow(
                        title: "Ramadan Calendar",
                        detail: "Hijri date calculations based on the Umm al-Qura calendar system."
                    )
                }
                .padding(.vertical, 4)
            } header: {
                Text("Data Sources & Attributions")
            }
            .listRowBackground(Color.suhoorSurface)

            // MARK: - Acknowledgments
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Special thanks to the open-source community and Islamic scholars who have made accurate prayer time calculations accessible to developers worldwide.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Acknowledgments")
            }
            .listRowBackground(Color.suhoorSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.suhoorIndigo)
        .foregroundStyle(Color.suhoorTextPrimary)
        .navigationTitle("About")
    }

    private func dataSourceRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.bold())
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
