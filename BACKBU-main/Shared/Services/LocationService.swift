import Foundation
import CoreLocation
import Combine
import UIKit

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: Public
    @Published var currentLocation: CLLocation?
    var onLocation: ((CLLocation) -> Void)?

    /// Expose current authorization so UI can react (Start button, etc.)
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    /// Open the app’s Settings page (used when permission is denied).
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: Private
    private let manager = CLLocationManager()
    private var wantsUpdates = false

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
        switch manager.authorizationStatus {
        case .notDetermined:
            if Self.hasBackgroundLocationCapability {
                manager.requestAlwaysAuthorization()
            } else {
                manager.requestWhenInUseAuthorization()
            }
        default:
            break
        }
    }

    // MARK: Control
    func start() {
        wantsUpdates = true
        maybeStartIfAuthorized()
        if manager.authorizationStatus == .notDetermined {
            requestPermissions()
        }
    }

    func stop() {
        wantsUpdates = false
        manager.stopUpdatingLocation()
    }

    private func maybeStartIfAuthorized() {
        guard wantsUpdates else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    // MARK: CLLocationManagerDelegate (Swift 6 friendly)
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in self.maybeStartIfAuthorized() }
    }

    // Keep for older iOS; forward to the new one
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
        // Common on Simulator without a simulated route
        // print("Location error:", error.localizedDescription)
    }
}
