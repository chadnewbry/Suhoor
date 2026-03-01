import Foundation
import CoreLocation
import SwiftUI

/// Manages device location for prayer time calculations.
@MainActor
@Observable
final class LocationService: NSObject {
    static let shared = LocationService()

    enum AuthorizationState {
        case notDetermined
        case authorized
        case denied
        case restricted
    }

    private(set) var currentLocation: CLLocationCoordinate2D?
    private(set) var currentPlacemark: CLPlacemark?
    private(set) var authorizationState: AuthorizationState = .notDetermined
    private(set) var isLocating = false
    private(set) var errorMessage: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        updateAuthState(manager.authorizationStatus)
    }

    // MARK: - Public

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func detectLocation() {
        errorMessage = nil
        isLocating = true
        manager.requestLocation()
    }

    /// Build a LocationData from the currently detected location.
    var detectedLocationData: LocationData? {
        guard let coord = currentLocation else { return nil }
        return LocationData(
            latitude: coord.latitude,
            longitude: coord.longitude,
            name: currentPlacemark?.locality ?? currentPlacemark?.administrativeArea,
            timeZoneIdentifier: currentPlacemark?.timeZone?.identifier ?? TimeZone.current.identifier
        )
    }

    /// Geocode a city name into coordinates.
    func geocode(query: String) async -> LocationData? {
        do {
            let placemarks = try await geocoder.geocodeAddressString(query)
            guard let place = placemarks.first, let loc = place.location else { return nil }
            return LocationData(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                name: place.locality ?? place.administrativeArea ?? query,
                timeZoneIdentifier: place.timeZone?.identifier ?? TimeZone.current.identifier
            )
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private func updateAuthState(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: authorizationState = .notDetermined
        case .authorizedWhenInUse, .authorizedAlways: authorizationState = .authorized
        case .denied: authorizationState = .denied
        case .restricted: authorizationState = .restricted
        @unknown default: authorizationState = .denied
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: @preconcurrency CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location.coordinate
            self.isLocating = false

            // Reverse geocode
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                self.currentPlacemark = placemarks.first
            } catch {
                // Non-critical — we still have coordinates
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLocating = false
            self.errorMessage = error.localizedDescription
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.updateAuthState(manager.authorizationStatus)
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                self.detectLocation()
            }
        }
    }
}
