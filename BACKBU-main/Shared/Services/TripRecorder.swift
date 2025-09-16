import Foundation
import Combine
import CoreLocation
import ActivityKit
import SwiftUI

@MainActor
final class TripRecorder: ObservableObject {
    @Published private(set) var activeTrip: Trip?

    private let store: Store
    private let location: LocationService
    private let zones: SpeedZoneMonitor
    private var activity: Activity<TripActivityAttributes>?

    init(store: Store, location: LocationService, zones: SpeedZoneMonitor) {
        self.store = store
        self.location = location
        self.zones = zones
        self.location.onLocation = { [weak self] in self?.ingest($0) }
    }

    // MARK: - Public
    func start() {
        guard activeTrip == nil else { return }
        activeTrip = Trip(startedAt: Date(), points: [])
        startActivity()
        location.start()
    }

    func stop() async {
        guard var trip = activeTrip else { return }
        trip.endedAt = Date()
        activeTrip = trip
        endActivity()
        location.stop()
        await store.add(trip)
    }

    /// Stop if last recorded speed is very low (no nonexistent `lastPointTime`)
    func stopIfIdle() async {
        guard let trip = activeTrip else { return }
        if let s = trip.points.last?.speedKmh, s < 3 {
            await stop()
        }
    }

    func addIncident(_ type: IncidentType) {
        guard var t = activeTrip, let loc = location.currentLocation else { return }
        t.incidents.append(.init(time: Date(), type: type, coordinate: .init(loc.coordinate)))
        activeTrip = t
    }

    // MARK: - Live Activity
    private func startActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled, let trip = activeTrip else { return }
        let attr = TripActivityAttributes(tripId: trip.id)
        let state = TripActivityAttributes.ContentState(speedKmh: 0, distanceKm: 0, durationSec: 0, overSpeed: false)
        activity = try? Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
    }

    private func snapshotContentState() -> TripActivityAttributes.ContentState {
        guard let trip = activeTrip else {
            return .init(speedKmh: 0, distanceKm: 0, durationSec: 0, overSpeed: false)
        }
        let kmh = Int((trip.points.last?.speedKmh ?? 0).rounded())
        let distKm = trip.distanceMeters / 1000
        let durSec = Int(trip.duration)
        var over = false
        if let last = trip.points.last,
           let limit = zones.zoneLimit(for: last.coord.location.coordinate, in: store.speedZones) {
            over = Double(kmh) > limit
        }
        return .init(speedKmh: kmh, distanceKm: distKm, durationSec: durSec, overSpeed: over)
    }

    /// End the activity (handles both pre-iOS 16.2 and 16.2+)
    private func endActivity() {
        Task {
            if #available(iOS 16.2, *) {
                await activity?.end(
                    content: .init(state: snapshotContentState(), staleDate: nil),
                    dismissalPolicy: .immediate
                )
            } else {
                await activity?.end(dismissalPolicy: .immediate)
            }
        }
        activity = nil
    }

    // MARK: - Stream ingest
    private func ingest(_ loc: CLLocation) {
        guard var trip = activeTrip else { return }
        let kmh = max(0, loc.speed * 3.6)
        let p = TrackPoint(
            timestamp: Date(),
            coord: .init(loc.coordinate),
            speedKmh: kmh,
            accuracy: loc.horizontalAccuracy,
            altitude: loc.verticalAccuracy >= 0 ? loc.altitude : .nan
        )
        trip.points.append(p)
        activeTrip = trip

        // Over-speed check + live activity update
        if let limit = zones.zoneLimit(for: loc.coordinate, in: store.speedZones), kmh > limit {
            zones.notifyOverSpeed(limit: limit, speed: kmh)
            Task {
                let st = TripActivityAttributes.ContentState(
                    speedKmh: Int(kmh.rounded()),
                    distanceKm: (trip.distanceMeters / 1000),
                    durationSec: Int(trip.duration),
                    overSpeed: true
                )
                await activity?.update(.init(state: st, staleDate: nil))
            }
        } else {
            Task {
                let st = TripActivityAttributes.ContentState(
                    speedKmh: Int(kmh.rounded()),
                    distanceKm: (trip.distanceMeters / 1000),
                    durationSec: Int(trip.duration),
                    overSpeed: false
                )
                await activity?.update(.init(state: st, staleDate: nil))
            }
        }
    }
}
