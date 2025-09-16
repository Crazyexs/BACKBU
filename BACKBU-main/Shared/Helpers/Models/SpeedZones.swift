import Foundation
import CoreLocation

struct SpeedZone: Codable, Identifiable {
    let id = UUID()
    var title: String
    var center: CLLocationCoordinate2D_Codable
    var radius: Double // meters
    var speedLimitKmh: Double
}
