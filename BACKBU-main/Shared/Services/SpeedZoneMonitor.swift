import CoreLocation
import UserNotifications
import SwiftUI
import Combine

final class SpeedZoneMonitor: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var currentLimit: Double?

    override init() {
        super.init()
        manager.delegate = self
    }

    func sync(zones: [SpeedZone]) {
        // remove previously monitored regions
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }

        for z in zones {
            let region = CLCircularRegion(center: z.center.location.coordinate,
                                          radius: z.radius,
                                          identifier: z.id.uuidString)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
        }
    }

    func zoneLimit(for coordinate: CLLocationCoordinate2D, in zones: [SpeedZone]) -> Double? {
        for z in zones {
            let c = z.center.location.coordinate
            let here = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let center = CLLocation(latitude: c.latitude, longitude: c.longitude)
            if here.distance(from: center) <= z.radius {
                return z.speedLimitKmh
            }
        }
        return nil
    }

    static func notify(title: String, body: String) {
        let c = UNMutableNotificationContent()
        c.title = title
        c.body = body
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: c, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }

    func notifyOverSpeed(limit: Double, speed: Double) {
        Self.notify(
            title: "Speeding",
            body: "Limit \(Int(limit)) km/h — you’re at \(Int(speed)) km/h."
        )
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) { }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)  { }
}
