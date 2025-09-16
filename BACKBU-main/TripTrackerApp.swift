import SwiftUI

@main
struct TripTrackerApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack { MapScreen() }
                    .tabItem { Label("Map", systemImage: "map") }

                NavigationStack { TripsScreen() }
                    .tabItem { Label("Trips", systemImage: "list.bullet") }

                NavigationStack { StatisticsScreen() }
                    .tabItem { Label("Statistics", systemImage: "chart.bar") }

                NavigationStack { SettingsScreen() }
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            .environmentObject(state)             
            .environmentObject(state.settings)     
            .preferredColorScheme(.dark)
        }
    }
}
