import WidgetKit
import SwiftUI

struct LastTripWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LastTripWidget", provider: Provider()) { entry in
            VStack(alignment:.leading) {
                Text("Last Trip").font(.caption).foregroundStyle(.secondary)
                Text(entry.title).font(.headline)
                HStack {
                    Label(entry.distance, systemImage: "map")
                    Label(entry.max, systemImage: "gauge")
                }.font(.caption)
            }.padding()
        }
        .configurationDisplayName("Last Trip")
        .description("Shows your most recent trip.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }

    struct Provider: TimelineProvider {
        func placeholder(in: Context) -> Entry { sample }
        func getSnapshot(in: Context, completion: @escaping (Entry) -> ()) { completion(sample) }
        func getTimeline(in: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            let url = AppGroup.containerURL.appendingPathComponent("data/trips.json")
            var entry = sample
            if let d = try? Data(contentsOf: url),
               let trips = try? JSONDecoder().decode([Trip].self, from: d),
               let t = trips.first {
                entry = Entry(
                    date: Date(),
                    title: t.startedAt.formatted(date:.abbreviated, time:.shortened),
                    distance: String(format:"%.1f km", t.distanceMeters/1000),
                    max: String(format:"%.0f km/h", t.maxSpeedKmh)
                )
            }
            completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900))))
        }
        struct Entry: TimelineEntry { var date: Date; var title: String; var distance: String; var max: String }
        var sample: Entry { .init(date: .now, title: "Today 10:32", distance: "12.4 km", max: "112 km/h") }
    }
}
