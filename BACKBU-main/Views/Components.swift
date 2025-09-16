import SwiftUI
import Charts

struct StatTile: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Text(value).font(.title2).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct SpeedChart: View {
    let points: [TrackPoint]
    var body: some View {
        Chart {
            ForEach(points) { p in
                LineMark(x: .value("t", p.timestamp), y: .value("km/h", p.speedKmh))
            }
        }
        .chartYScale(domain: 0...(max(points.map{$0.speedKmh}.max() ?? 100, 100)))
        .frame(height: 180)
    }
}

struct IncidentButton: View {
    let title: String
    let system: String
    var action: ()->Void
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: system)
                .font(.subheadline)
                .padding(.vertical, 8).padding(.horizontal, 10)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}
