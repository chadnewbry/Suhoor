import SwiftUI
import MapKit

struct MosqueItem: Identifiable {
    let id = UUID()
    let name: String?
    let coordinate: CLLocationCoordinate2D
}

struct NearbyMosquesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var position: MapCameraPosition = .automatic
    @State private var mosques: [MosqueItem] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    ForEach(mosques) { mosque in
                        Annotation(mosque.name ?? "Mosque", coordinate: mosque.coordinate) {
                            VStack(spacing: 2) {
                                Image(systemName: "building.columns.fill")
                                    .font(.body)
                                    .foregroundStyle(Color.suhoorGold)
                                    .padding(6)
                                    .background(Color.suhoorIndigo, in: Circle())
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                if isSearching {
                    ProgressView()
                        .tint(Color.suhoorGold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .navigationTitle("Nearby Mosques")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.suhoorGold)
                }
            }
            .task { await searchMosques() }
        }
    }

    private func searchMosques() async {
        var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        if let location = UserSettings.shared.selectedLocation {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        position = .region(region)

        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "mosque"
        request.region = region

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            mosques = response.mapItems.map { item in
                MosqueItem(name: item.name, coordinate: item.placemark.coordinate)
            }
        } catch {
            // Silently handle
        }
        isSearching = false
    }
}

#Preview {
    NearbyMosquesView()
        .preferredColorScheme(.dark)
}
