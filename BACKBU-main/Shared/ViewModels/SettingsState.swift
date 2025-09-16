import Foundation
import Combine

@MainActor
final class SettingsState: ObservableObject {
    @Published var autoStartMotion = true
    @Published var autoStartBluetooth = true
    @Published var autoStopAfterMinutesStill = 5
    @Published var carBluetoothNames: [String] = ["Car", "BMW", "Toyota", "Car Audio"]
}
