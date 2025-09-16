import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        Form {
            Section("Data Management") {
                Button(role:.destructive) { Task { await state.store.deleteAll() } }
                label: { Label("Delete All Data", systemImage: "trash") }
            }
            Section("Auto Start/Stop") {
                Toggle("Auto-start when driving", isOn: $state.settings.autoStartMotion)
                Toggle("Auto-start on car Bluetooth", isOn: $state.settings.autoStartBluetooth)
                Stepper("Auto-stop after \(state.settings.autoStopAfterMinutesStill) min still", value: $state.settings.autoStopAfterMinutesStill, in: 1...15)
                NavigationLink("Car Bluetooth Names") { BTNamesEditor(names: $state.settings.carBluetoothNames) }
            }
            Section("Speed Sections") {
                NavigationLink("Manage Speed Sections") { SpeedSectionsScreen() }
            }
            Section("Speed Zones") {
                NavigationLink("Manage Speed Zones") { SpeedZonesScreen() }
            }
        }
        .navigationTitle("Settings")
    }
}

struct BTNamesEditor: View {
    @Binding var names: [String]
    @State private var newName = ""
    var body: some View {
        Form {
            Section("Add") {
                HStack { TextField("e.g. BMW", text: $newName)
                    Button("Add") { if !newName.isEmpty { names.append(newName); newName = "" } }
                }
            }
            Section("Current") {
                ForEach(names, id:\.self) { Text($0) }.onDelete { names.remove(atOffsets: $0) }
            }
        }.navigationTitle("Car Bluetooth")
    }
}
