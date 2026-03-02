import SwiftUI
import CoreLocation

// MARK: - Qibla Heading Manager

@MainActor
final class QiblaHeadingManager: NSObject, ObservableObject {
    @Published var deviceHeading: Double = 0
    @Published var qiblaBearing: Double = 0
    @Published var isAvailable = false
    @Published var errorMessage: String?

    private let locationManager = CLLocationManager()
    private static let kaabaCoord = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func start() {
        guard CLLocationManager.headingAvailable() else {
            errorMessage = "Compass not available on this device"
            return
        }
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        isAvailable = true
    }

    func stop() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }

    private func calculateQiblaBearing(from coordinate: CLLocationCoordinate2D) {
        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        let lat2 = Self.kaabaCoord.latitude * .pi / 180
        let lon2 = Self.kaabaCoord.longitude * .pi / 180
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var bearing = atan2(y, x) * 180 / .pi
        if bearing < 0 { bearing += 360 }
        qiblaBearing = bearing
    }

    var qiblaDirection: Double {
        var direction = qiblaBearing - deviceHeading
        if direction < 0 { direction += 360 }
        return direction
    }

    var cardinalDirection: String {
        let bearing = qiblaBearing
        switch bearing {
        case 337.5..<360, 0..<22.5: return "N"
        case 22.5..<67.5: return "NE"
        case 67.5..<112.5: return "E"
        case 112.5..<157.5: return "SE"
        case 157.5..<202.5: return "S"
        case 202.5..<247.5: return "SW"
        case 247.5..<292.5: return "W"
        case 292.5..<337.5: return "NW"
        default: return "N"
        }
    }
}

extension QiblaHeadingManager: @preconcurrency CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        Task { @MainActor in
            self.deviceHeading = newHeading.magneticHeading
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.calculateQiblaBearing(from: location.coordinate)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Qibla Compass View

struct QiblaCompassView: View {
    @StateObject private var heading = QiblaHeadingManager()

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "location.north.circle.fill")
                    .font(.body)
                    .foregroundStyle(Color.suhoorGold)
                Text("Qibla Direction")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.suhoorTextPrimary)
                Spacer()
                Text("\(Int(heading.qiblaBearing))° \(heading.cardinalDirection)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color.suhoorTextSecondary)
            }

            ZStack {
                // Compass ring
                Circle()
                    .stroke(Color.suhoorDivider, lineWidth: 2)
                    .frame(width: 160, height: 160)

                // Cardinal directions
                ForEach(["N", "E", "S", "W"], id: \.self) { dir in
                    let angle: Double = switch dir {
                    case "N": 0
                    case "E": 90
                    case "S": 180
                    case "W": 270
                    default: 0
                    }
                    Text(dir)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(dir == "N" ? Color.suhoorGold : Color.suhoorTextSecondary)
                        .offset(y: -72)
                        .rotationEffect(.degrees(angle))
                }
                .rotationEffect(.degrees(-heading.deviceHeading))

                // Qibla needle
                VStack(spacing: 0) {
                    Image(systemName: "arrow.up")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.suhoorGold)
                    Text("Qibla")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.suhoorGold)
                }
                .rotationEffect(.degrees(heading.qiblaDirection))
                .animation(.easeInOut(duration: 0.3), value: heading.qiblaDirection)

                // Kaaba icon at center
                Image(systemName: "building.columns.fill")
                    .font(.caption)
                    .foregroundStyle(Color.suhoorAmber.opacity(0.4))
            }
            .frame(height: 170)

            if let error = heading.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(Color.suhoorWarning)
            }
        }
        .padding(16)
        .background(Color.suhoorSurface, in: RoundedRectangle(cornerRadius: 16))
        .onAppear { heading.start() }
        .onDisappear { heading.stop() }
    }
}

#Preview {
    QiblaCompassView()
        .padding()
        .background(Color.suhoorIndigo)
        .preferredColorScheme(.dark)
}
