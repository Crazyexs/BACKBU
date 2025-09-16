import WidgetKit
import SwiftUI

struct WeekWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WeekWidget", provider: Provider()) { e in
            VStack(alignment:.leading) {
                Text("This Week").font(.caption).foregroundStyle(.secondary)
                Text(e.distance).font(.title2).bold()
                Text("\(e.trips) trips").font(.caption)
            }.padding()
        }
        .configurationDisplayName("Weekly Totals")
        .description("Trips and distance this week.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }

    struct Provider: TimelineProvider {
        func placeholder(in: Context) -> Entry { .sample }
        func getSnapshot(in: Context, completion: @escaping (Entry)->()) { completion(.sample) }
        func getTimeline(in: Context, completion: @escaping (Timeline<Entry>)->()) {
            let url = AppGroup.containerURL.appendingPathComponent("data/trips.json")
            var e = Entry.sample
            if let d = try? Data(contentsOf: url),
               let trips = try? JSONDecoder().decode([Trip].self, from: d) {
                let cal = Calendar.current
                let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
                let weekTrips = trips.filter { ($0.startedAt >= start) }
                let km = weekTrips.map{$0.distanceMeters}.reduce(0,+)/1000
                e = Entry(date: .now, trips: weekTrips.count, distance: String(format:"%.1f km", km))
            }
            completion(Timeline(entries: [e], policy: .after(.now.addingTimeInterval(1800))))
        }
        struct Entry: TimelineEntry { var date: Date; var trips: Int; var distance: String
            static let sample = Entry(date: .now, trips: 3, distance: "42.7 km") }
    }
}
