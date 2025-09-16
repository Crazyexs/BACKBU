import WidgetKit
import SwiftUI
import ActivityKit

struct TripLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripActivityAttributes.self) { context in
            VStack(alignment: .leading) {
                Text("Trip Active")
                    .font(.headline)
                    .foregroundStyle(context.state.overSpeed ? .orange : .blue)
                Text(String(format: "%.1f km", context.state.distanceKm))
                Text("\(context.state.durationSec)s")
                    .font(.title2)
            }
            .padding()
            .background(.black.opacity(0.6))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 0) {
                        Text("\(context.state.speedKmh)").bold()
                        Text(" km/h")
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(String(format: "%.1f km", context.state.distanceKm))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.state.durationSec)s")
                }
            } compactLeading: {
                Text("\(context.state.speedKmh)")
            } compactTrailing: {
                Text("km/h").font(.caption2)
            } minimal: {
                Text("\(context.state.speedKmh)")
            }
        }
    }
}
