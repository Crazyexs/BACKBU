import CoreLocation
import UserNotifications
import SwiftUI
import Foundation
import Combine


final class SpeedZoneMonitor: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLimit: Double? // km/h

    override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }

    func sync(zones: [SpeedZone]) {
        manager.monitoredRegions.forEach { manager.stopMonitoring(for: $0) }
        for z in zones {
            let r = CLCircularRegion(center: CLLocationCoordinate2D(latitude: z.center.latitude, longitude: z.center.longitude),
                                     radius: z.radius, identifier: z.id.uuidString)
            r.notifyOnEntry = true; r.notifyOnExit = true
            manager.startMonitoring(for: r)
        }
    }

    func zoneLimit(for coordinate: CLLocationCoordinate2D, in zones: [SpeedZone]) -> Double? {
        for z in zones {
            let c = CLLocation(latitude: z.center.latitude, longitude: z.center.longitude)
            if c.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) <= z.radius {
                return z.speedLimitKmh
            }
        }
        return nil
    }
    
    func notifyOverSpeed(limit: Double, speed: Double) {
    Self.notify(
        title: "Speeding",
        body: "Limit \(Int(limit)) km/h — you’re at \(Int(speed)) km/h."
    )
}


    // Keep track of entry/exit to update currentLimit (best-effort).
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) { }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)  { }

    static func notify(title: String, body: String) {
        let c = UNMutableNotificationContent()
        c.title = title; c.body = body
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: c, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }
}
