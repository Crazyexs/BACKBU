import ActivityKit
import Foundation

struct TripActivityAttributes: ActivityAttributes, Identifiable {
    let id = UUID()
    public struct ContentState: Codable, Hashable {
        var speedKmh: Int
        var distanceKm: Double
        var durationSec: Int
        var overSpeed: Bool
    }
    var tripId: UUID
}
