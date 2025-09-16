import SwiftUI
import MapKit

struct TripDetailScreen: View {
    @EnvironmentObject var state: AppState
    @State var trip: Trip
    @State private var showShare = false

    var body: some View {
        ScrollView {
            Map {
                let coords = trip.points.map { CLLocationCoordinate2D(latitude: $0.coord.latitude, longitude: $0.coord.longitude) }
                if coords.count > 1 { MapPolyline(coordinates: coords).stroke(.blue, lineWidth: 6) }
                if let first = coords.first { MapPolyline(coordinates: [first]).stroke(.clear) }
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 16)).padding()

            HStack { StatTile(title:"Date", value: trip.startedAt.formatted(date:.abbreviated, time:.shortened))
                    StatTile(title:"Duration", value:"\(Int(trip.duration)) s") }.padding(.horizontal)
            HStack { StatTile(title:"Distance", value:String(format:"%.2f km", trip.distanceMeters/1000))
                    StatTile(title:"Avg Speed", value:String(format:"%.1f km/h", trip.avgSpeedKmh)) }.padding(.horizontal)
            HStack { StatTile(title:"Max Speed", value:String(format:"%.1f km/h", trip.maxSpeedKmh))
                    StatTile(title:"0–100", value: trip.zeroToHundredSec.map{ String(format:"%.1f s",$0)} ?? "—") }.padding(.horizontal)

            if !trip.badges.isEmpty {
                GroupBox("Achievements") {
                    HStack { ForEach(trip.badges, id:\.self) { Text($0.title).padding(8).background(.thinMaterial, in: Capsule()) } }
                }.padding(.horizontal)
            }

            GroupBox("Speed Profile") { SpeedChart(points: trip.points) }.padding()
        }
        .navigationTitle("Trip Details")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button("Share Poster") { if let url = PosterService.renderPNG(for: trip) { share(url) } }
                    Button("Export GPX") { writeAndShare(data: ExportService.gpx(for: trip), filename: "trip.gpx") }
                    Button("Export CSV") { writeAndShare(data: ExportService.csv(for: trip), filename: "trip.csv") }
                    Button(role:.destructive) {
                        if let i = state.store.trips.firstIndex(where: {$0.id == trip.id}) {
                            Task { await state.store.delete(IndexSet(integer: i)) }
                        }
                    } label: { Label("Delete Trip", systemImage: "trash") }
                } label: { Image(systemName:"square.and.arrow.up") }
            }
        }
    }

    private func writeAndShare(data: Data, filename: String) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url); share(url)
    }
    private func share(_ url: URL) {
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(av, animated: true)
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? { connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.first }
}
