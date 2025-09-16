import SwiftUI

struct StatisticsScreen: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        let trips = state.store.trips
        let totalDist = trips.map{$0.distanceMeters}.reduce(0,+)/1000
        let totalTime = trips.map{$0.duration}.reduce(0,+)
        let maxSpeed = trips.map{$0.maxSpeedKmh}.max() ?? 0
        let avgSpeed = trips.isEmpty ? 0 : (trips.map{$0.avgSpeedKmh}.reduce(0,+)/Double(trips.count))

        ScrollView {
            VStack(spacing: 12) {
                HStack { StatTile(title:"Total Trips", value:"\(trips.count)")
                        StatTile(title:"Total Distance", value:String(format:"%.2f km", totalDist)) }
                HStack { StatTile(title:"Total Time", value:"\(Int(totalTime)) s")
                        StatTile(title:"Max Speed", value:String(format:"%.1f km/h", maxSpeed)) }
                StatTile(title:"Avg Speed", value:String(format:"%.1f km/h", avgSpeed))
            }
            .padding(.horizontal)
        }
        .navigationTitle("Statistics")
    }
}
