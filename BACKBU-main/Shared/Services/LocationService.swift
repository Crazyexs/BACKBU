import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Public
    @Published var currentLocation: CLLocation?
    var onLocation: ((CLLocation) -> Void)?

    // MARK: - Private
    private let manager = CLLocationManager()

    private static var hasBackgroundLocationCapability: Bool {
        if let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String] {
            return modes.contains("location")
        }
        return false
    }

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        manager.pausesLocationUpdatesAutomatically = true

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

    // MARK: - Permissions
    func requestPermissions() {
        if Self.hasBackgroundLocationCapability {
            manager.requestAlwaysAuthorization()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - Control
    func start() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        manager.startUpdatingLocation()
        // manager.startUpdatingHeading()
    }

    func stop() {
        manager.stopUpdatingLocation()
        // manager.stopUpdatingHeading()
    }

    // MARK: - CLLocationManagerDelegate (Swift 6 friendly)
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = loc
            self.onLocation?(loc)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // If needed, react to status changes on main
        Task { @MainActor in
            // e.g. start after authorization
            // if status == .authorizedAlways || status == .authorizedWhenInUse { self.start() }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Log on main if you want
        Task { @MainActor in
            // print("Location error:", error.localizedDescription)
        }
    }
}
