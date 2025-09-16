import WidgetKit
import ActivityKit
import SwiftUI

struct TripLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripActivityAttributes.self) { context in
            HStack {
                VStack(alignment: .leading) {
                    Text("\(context.state.speedKmh) km/h").font(.largeTitle.bold())
                    Text(String(format:"%.2f km • %ds", context.state.distanceKm, context.state.durationSec))
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: context.state.overSpeed ? "exclamationmark.triangle.fill" : "car.fill")
                    .foregroundStyle(context.state.overSpeed ? .orange : .blue).font(.title2)
            }
            .padding()
            .background(.black.opacity(0.6))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) { Text("\(context.state.speedKmh)").bold() + Text(" km/h") }
                DynamicIslandExpandedRegion(.trailing) { Text(String(format:"%.1f km", context.state.distanceKm)) }
                DynamicIslandExpandedRegion(.bottom) { Text("\(context.state.durationSec)s") }
            } compactLeading: { Text("\(context.state.speedKmh)") }
              compactTrailing: { Text("km/h").font(.caption2) }
              minimal: { Text("\(context.state.speedKmh)") }
        }
    }
}
