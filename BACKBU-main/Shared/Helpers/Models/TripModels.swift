import Foundation
import CoreLocation

struct TrackPoint: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let coord: CLLocationCoordinate2D_Codable
    let speedKmh: Double
    let accuracy: Double
    let altitude: Double?
}

struct Trip: Codable, Identifiable {
    var id = UUID()
    var startedAt: Date
    var endedAt: Date?
    var points: [TrackPoint] = []
    var incidents: [Incident] = []
    var badges: [Badge] = []

    // MARK: Derived
    var distanceMeters: Double {
        guard points.count > 1 else { return 0 }
        return (1..<points.count).reduce(0) { acc, i in
            acc + points[i-1].coord.location.distance(from: points[i].coord.location)
        }
    }
    var duration: TimeInterval { (endedAt ?? Date()).timeIntervalSince(startedAt) }
    var avgSpeedKmh: Double {
        let hrs = duration / 3600
        return hrs > 0 ? (distanceMeters / 1000) / hrs : 0
    }
    var maxSpeedKmh: Double { points.map(\.speedKmh).max() ?? 0 }

    var zeroToHundredSec: Double? {
        guard points.count > 1 else { return nil }
        var t0: Date?
        for p in points {
            if t0 == nil, p.speedKmh <= 5 { t0 = p.timestamp }
            if let s = t0, p.speedKmh >= 100 { return p.timestamp.timeIntervalSince(s) }
        }
        return nil
    }
}

struct CLLocationCoordinate2D_Codable: Codable {
    let latitude: Double
    let longitude: Double
    var location: CLLocation { .init(latitude: latitude, longitude: longitude) }
    init(_ c: CLLocationCoordinate2D) { latitude = c.latitude; longitude = c.longitude }
}

enum IncidentType: String, Codable, CaseIterable { case brake, accel, hazard, note, photo }

struct Incident: Codable, Identifiable {
    let id = UUID()
    let time: Date
    let type: IncidentType
    let coordinate: CLLocationCoordinate2D_Codable
    var note: String?
    var photoFilename: String?
}
