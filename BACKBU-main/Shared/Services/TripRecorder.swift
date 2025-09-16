import Foundation
import CoreLocation
import ActivityKit
import SwiftUI
import Combine


@MainActor
final class TripRecorder: ObservableObject {
    @Published private(set) var activeTrip: Trip?

    private let store: Store
    private let location: LocationService
    private let zones: SpeedZoneMonitor
    private var activity: Activity<TripActivityAttributes>?

    init(store: Store, location: LocationService, zones: SpeedZoneMonitor) {
        self.store = store; self.location = location; self.zones = zones
        self.location.onLocation = { [weak self] loc in self?.ingest(loc) }
    }

    func start() {
        guard activeTrip == nil else { return }
        activeTrip = Trip(startedAt: Date(), endedAt: nil, points: [])
        zones.sync(zones: store.speedZones)
        location.start()
        startActivity()
    }

    func stop() async {
        guard var trip = activeTrip else { return }
        trip.endedAt = Date()
        trip.badges = earnedBadges(for: trip)
        activeTrip = nil
        location.stop()
        await store.add(trip)
        endActivity()
    }

    func stopIfIdle() async {
        guard let trip = activeTrip else { return }
        // stop if last speed near zero for N minutes
        let last = trip.points.last
        if let s = last?.speedKmh, s < 3 {
            await stop()
        }
    }

    private func startActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled, let trip = activeTrip else { return }
        let attr = TripActivityAttributes(tripId: trip.id)
        let state = TripActivityAttributes.ContentState(speedKmh: 0, distanceKm: 0, durationSec: 0, overSpeed: false)
        activity = try? Activity.request(attributes: attr, content: .init(state: state, staleDate: nil))
    }

    private func endActivity() { Task { await activity?.end(dismissalPolicy: .immediate) }; activity = nil }

    private func ingest(_ loc: CLLocation) {
        guard var trip = activeTrip else { return }
        let kmh = max(0, loc.speed * 3.6)
        let p = TrackPoint(timestamp: Date(),
                           coord: .init(loc.coordinate),
                           speedKmh: kmh,
                           accuracy: loc.horizontalAccuracy,
                           altitude: loc.verticalAccuracy >= 0 ? loc.altitude : .nan)
        trip.points.append(p)
        activeTrip = trip

        // Speed zone alert
        if let limit = zones.zoneLimit(for: loc.coordinate, in: store.speedZones), kmh > limit {
            Haptics.warning()
            SpeedZoneMonitor.notify(title: "Over the limit", body: "Limit \(Int(limit)) km/h")
        }

        // Update Live Activity
        if let act = activity {
            let st = TripActivityAttributes.ContentState(
                speedKmh: Int(kmh.rounded()),
                distanceKm: trip.distanceMeters/1000,
                durationSec: Int(Date().timeIntervalSince(trip.startedAt)),
                overSpeed: {
                    if let limit = zones.zoneLimit(for: loc.coordinate, in: store.speedZones) { return kmh > limit }
                    return false
                }()
            )
            Task { await act.update(.init(state: st, staleDate: nil)) }
        }
    }

    // MARK: Incidents
    func addIncident(_ type: IncidentType, note: String? = nil, photoFilename: String? = nil) {
        guard var trip = activeTrip, let cl = location.currentLocation else { return }
        trip.incidents.append(.init(time: .now, type: type, coordinate: .init(cl.coordinate), note: note, photoFilename: photoFilename))
        activeTrip = trip
    }
}
