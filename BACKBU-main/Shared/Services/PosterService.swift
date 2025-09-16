import SwiftUI

struct TripPosterView: View {
    let trip: Trip
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trip Summary").font(.largeTitle.bold())
            Text(trip.startedAt.formatted(date: .abbreviated, time: .shortened)).foregroundStyle(.secondary)
            HStack {
                stat("Distance", String(format:"%.2f km", trip.distanceMeters/1000))
                stat("Time", "\(Int(trip.duration)) s")
                stat("Max", String(format:"%.0f km/h", trip.maxSpeedKmh))
            }
            .padding(.vertical, 8)
            Divider()
            HStack(spacing: 8) {
                ForEach(trip.badges, id:\.self) { b in
                    Text(b.title).padding(8).background(.ultraThinMaterial, in: Capsule())
                }
            }
        }
        .padding()
        .frame(width: 1024, height: 512, alignment: .topLeading)
        .background(LinearGradient(colors: [.black, .gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    private func stat(_ t:String,_ v:String)->some View{
        VStack(alignment:.leading){ Text(t).font(.subheadline); Text(v).font(.title).bold() }
            .frame(maxWidth:.infinity, alignment:.leading)
            .padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

enum PosterService {
    static func renderPNG(for trip: Trip) -> URL? {
        let view = TripPosterView(trip: trip)
        let renderer = ImageRenderer(content: view)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("trip_poster.png")
        guard let ui = renderer.uiImage, let data = ui.pngData() else { return nil }
        try? data.write(to: url); return url
    }
}
