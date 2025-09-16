import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Public surface
    @Published var currentLocation: CLLocation?
    var onLocation: ((CLLocation) -> Void)?

    // MARK: - Private
    private let manager = CLLocationManager()

    // Detect if Info.plist has "Required background modes" -> "App registers for location updates"
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

        // Only enable background updates when the app is provisioned for it
        // and NOT when running in the Simulator (Simulator often asserts here).
        #if targetEnvironment(simulator)
        let enableBackground = false
        #else
        let enableBackground = Self.hasBackgroundLocationCapability
        #endif

        if enableBackground {
            manager.allowsBackgroundLocationUpdates = true
            if #available(iOS 11.0, *) {
                manager.showsBackgroundLocationIndicator = true
            }
        } else {
            manager.allowsBackgroundLocationUpdates = false
            if #available(iOS 11.0, *) {
                manager.showsBackgroundLocationIndicator = false
            }
        }
    }

    // MARK: - Permissions
    func requestPermissions() {
        if Self.hasBackgroundLocationCapability {
            // If you’ve enabled the Background Mode, request Always for continuous tracking.
            manager.requestAlwaysAuthorization()
        } else {
            // Otherwise request When In Use to avoid assertion.
            manager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - Control
    func start() {
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // If you want heading/visits, enable them here conditionally.
            // manager.startUpdatingHeading()
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
        // manager.stopUpdatingHeading()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc
        onLocation?(loc)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Optionally react to status changes
        // print("Location auth changed:", status.rawValue)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Optionally report errors
        // print("Location error:", error.localizedDescription)
    }
}
