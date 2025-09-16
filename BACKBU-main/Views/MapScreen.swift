import SwiftUI
import MapKit

struct MapScreen: View {
    @EnvironmentObject var state: AppState
    @State private var position: MapCameraPosition = .userLocation(
        followsHeading: false,
        fallback: .automatic
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                if let t = state.recorder.activeTrip {
                    let coords = t.points.map {
                        CLLocationCoordinate2D(latitude: $0.coord.latitude,
                                               longitude: $0.coord.longitude)
                    }
                    if coords.count > 1 {
                        MapPolyline(coordinates: coords)
                            .stroke(.blue, lineWidth: 6)
                    }
                }
                UserAnnotation()
            }
            .mapStyle(.standard) // Apple Maps
            .mapControls { MapUserLocationButton(); MapPitchToggle() }
            .ignoresSafeArea()

            controls
        }
        .navigationTitle("Map")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { state.location.requestPermissions() } label: {
                    Image(systemName: "location")
                }
            }
        }
        .onAppear { state.configureAutoStart() }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            if let loc = state.location.currentLocation {
                Text("\(Int(max(0, loc.speed*3.6))) km/h")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            HStack(spacing: 10) {
                IncidentButton(title: "Brake",  system: "figure.seated.seatbelt") { state.recorder.addIncident(.brake) }
                IncidentButton(title: "Accel",  system: "bolt.fill")               { state.recorder.addIncident(.accel) }
                IncidentButton(title: "Hazard", system: "exclamationmark.triangle.fill") { state.recorder.addIncident(.hazard) }
            }
            .opacity(state.recorder.activeTrip == nil ? 0.3 : 1)

            HStack(spacing: 12) {
                if state.recorder.activeTrip == nil {
                    // Permission-aware Start
                    Button {
                        let status = state.location.authorizationStatus
                        switch status {
                        case .notDetermined:
                            state.location.requestPermissions()
                        case .denied, .restricted:
                            state.location.openSettings()
                        default:
                            state.recorder.start()
                            position = .userLocation(followsHeading: false, fallback: .automatic)
                        }
                    } label: {
                        Label("Start Tracking", systemImage: "play.fill")
                            .font(.headline)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    let t = state.recorder.activeTrip!
                    let km = t.distanceMeters / 1000
                    let secs = Int(Date().timeIntervalSince(t.startedAt))

                    Label {
                        Text(String(format: "%.2f km • %d s", km, secs))
                    } icon: {
                        Image(systemName: "speedometer")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    Button(role: .destructive) {
                        Task { await state.recorder.stop() }
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.headline)
                            .padding(.vertical, 12)
                            .frame(maxWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 18)
    }
}
