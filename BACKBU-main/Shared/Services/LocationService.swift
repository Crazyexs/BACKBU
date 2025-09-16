import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {

    // MARK: Public
    @Published var currentLocation: CLLocation?
    var onLocation: ((CLLocation) -> Void)?

    // MARK: Private
    private let manager = CLLocationManager()

    private static var hasBackgroundLocationCapability: Bool {
        (Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String])?.contains("location") ?? false
    }

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        manager.pausesLocationUpdatesAutomatically = true

        // Only allow background updates if the entitlement exists (and not on Simulator)
        #if targetEnvironment(simulator)
        let enableBackground = false
        #else
        let enableBackground = Self.hasBackgroundLocationCapability
        #endif

        if enableBackground {
            manager.allowsBackgroundLocationUpdates = true
            if #available(iOS 11.0, *) { manager.showsBackgroundLocationIndicator = true }
        } else {
            manager.allowsBackgroundLocationUpdates = false
            if #available(iOS 11.0, *) { manager.showsBackgroundLocationIndicator = false }
        }
    }

    // MARK: Permissions
    func requestPermissions() {
        // Don’t synchronously query status; let the delegate tell us when it changes.
        if Self.hasBackgroundLocationCapability {
            manager.requestAlwaysAuthorization()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }

    // MARK: Control
    func start() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        manager.startUpdatingLocation()
        // manager.startUpdatingHeading()
    }

    func stop() {
        manager.stopUpdatingLocation()
        // manager.stopUpdatingHeading()
    }

    // MARK: CLLocationManagerDelegate (Swift 6 friendly)
    /// Newer delegate – called whenever authorization changes. Use this instead of the old method.
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            // Example: auto-start when authorized (optional)
            let status = manager.authorizationStatus
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                // If you want to auto-start tracking when permission is granted, uncomment:
                // self.start()
                break
            default:
                break
            }
        }
    }

    /// Old-style delegate – keep for compatibility; forward to the new handler.
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManagerDidChangeAuthorization(manager)
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = loc
            self.onLocation?(loc)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            // Most common on Simulator if you haven't set a custom location
            // print("Location error:", error.localizedDescription)
        }
    }
}
