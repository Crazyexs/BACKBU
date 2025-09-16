import SwiftUI

struct TripsScreen: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        List {
            ForEach(state.store.trips) { trip in
                NavigationLink { TripDetailScreen(trip: trip) } label: {
                    VStack(alignment:.leading, spacing:4) {
                        Text(trip.startedAt.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                        HStack(spacing:12){
                            Label("\(String(format:"%.2f", trip.distanceMeters/1000)) km", systemImage: "map")
                            Label("\(Int(trip.duration)) s", systemImage: "clock")
                            Label("\(Int(trip.avgSpeedKmh)) km/h", systemImage: "gauge.with.dots.needle.bottom.50percent")
                        }.font(.subheadline).foregroundStyle(.secondary)
                    }.padding(.vertical, 4)
                }
            }
            .onDelete { idx in Task { await state.store.delete(idx) } }
        }
        .navigationTitle("Trips")
        .toolbar { EditButton() }
    }
}
