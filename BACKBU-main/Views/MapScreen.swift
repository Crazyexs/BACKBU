import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {
    @EnvironmentObject var state: AppState
    @State private var followHeading = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // iOS 17+ MapKit SwiftUI API:
            // add `fallback:` to userLocation
            Map(position: .constant(.userLocation(followsHeading: followHeading, fallback: .automatic))) {
                // Draw active trip polyline if available
                if let trip = state.recorder.activeTrip {
                    let coords: [CLLocationCoordinate2D] = trip.points.map {
                        CLLocationCoordinate2D(latitude: $0.coord.latitude, longitude: $0.coord.longitude)
                    }
                    if coords.count > 1 {
                        // Move style from initializer to the .stroke(_:style:) modifier
                        MapPolyline(coordinates: coords)
                            .stroke(.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    }
                }

                // Show the user location indicator
                UserAnnotation()
            }
            .ignoresSafeArea()

            // Bottom controls
            HStack(spacing: 16) {
                if state.recorder.activeTrip == nil {
                    Button {
                        Task { await state.recorder.start() }
                    } label: {
                        Label("Start", systemImage: "record.circle")
                            .font(.headline)
                            .padding(.vertical, 12)
                            .frame(maxWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
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
            .padding(.bottom, 18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding()
        }
    }
}
