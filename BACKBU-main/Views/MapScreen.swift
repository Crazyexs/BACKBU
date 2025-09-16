import SwiftUI
import MapKit

struct MapScreen: View {
    @EnvironmentObject var state: AppState
    @State private var follow = true

    var body: some View {
        ZStack(alignment: .bottom) {
            // add fallback: .automatic
            Map(position: .constant(.userLocation(followsHeading: false, fallback: .automatic))) {
                if let t = state.recorder.activeTrip {
                    let coords = t.points.map { CLLocationCoordinate2D(latitude: $0.coord.latitude, longitude: $0.coord.longitude) }
                    if coords.count > 1 {
                        // move StrokeStyle into the .stroke(_, style:) modifier
                        MapPolyline(coordinates: coords)
                            .stroke(.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    }
                }
                UserAnnotation()
            }
            .mapControls { MapUserLocationButton(); MapPitchToggle() }
            .ignoresSafeArea()

            controls
        }
        .navigationTitle("Map")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { state.location.requestPermissions() } label: { Image(systemName:"location") }
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
                IncidentButton(title: "Accel",  system: "bolt.fill")                 { state.recorder.addIncident(.accel) }
                IncidentButton(title: "Hazard", system: "exclamationmark.triangle.fill") { state.recorder.addIncident(.hazard) }
            }
            .opacity(state.recorder.activeTrip == nil ? 0.3 : 1)

            HStack(spacing: 12) {
                if state.recorder.activeTrip == nil {
                    Button {
                        state.recorder.start()
                    } label: {
                        Label("Start Tracking", systemImage: "play.fill")
                            .font(.headline).padding(.vertical, 14).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    let t = state.recorder.activeTrip!
                    Label("\(String(format:"%.2f", t.distanceMeters/1000)) km • \(Int(Date().timeIntervalSince(t.startedAt))) s", systemImage: "speedometer")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .padding(8).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    Button(role: .destructive) {
                        Task { await state.recorder.stop() }
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.headline).padding(.vertical, 12).frame(maxWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 18)
    }
}
