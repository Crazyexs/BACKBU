import SwiftUI
import MapKit

struct SpeedZonesScreen: View {
    @EnvironmentObject var state: AppState
    @State private var title = "School"
    @State private var limit = 30.0
    @State private var radius = 200.0
    @State private var center = CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018) // Bangkok default

    var body: some View {
        Form {
            Section("New Zone") {
                TextField("Title", text: $title)
                Stepper("Limit: \(Int(limit)) km/h", value: $limit, in: 10...140, step: 5)
                Stepper("Radius: \(Int(radius)) m", value: $radius, in: 50...1000, step: 10)
                Map(initialPosition: .region(.init(center: center, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))), interactionModes: .all)
                    .frame(height: 200).clipShape(RoundedRectangle(cornerRadius: 12))
                Button {
                    state.store.speedZones.append(.init(title: title, center: .init(center), radius: radius, speedLimitKmh: limit))
                    Task { await state.store.save() }
                    state.zoneMonitor.sync(zones: state.store.speedZones)
                } label: { Label("Add Speed Zone", systemImage: "plus") }
            }
            Section("Existing") {
                ForEach(state.store.speedZones) { z in
                    VStack(alignment:.leading) {
                        Text(z.title).font(.headline)
                        Text("Limit \(Int(z.speedLimitKmh)) km/h • \(Int(z.radius)) m").foregroundStyle(.secondary)
                    }
                }.onDelete {
                    state.store.speedZones.remove(atOffsets: $0)
                    Task { await state.store.save() }
                    state.zoneMonitor.sync(zones: state.store.speedZones)
                }
            }
        }
        .navigationTitle("Speed Zones")
    }
}
