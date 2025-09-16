import AVFAudio
import Foundation

final class BluetoothAutoStarter {
    private var names: () -> [String] = { [] }
    private var onChange: ((Bool) -> Void)?
    private var observer: NSObjectProtocol?

    /// Start monitoring the current audio route to detect car Bluetooth.
    func start(whitelist: @escaping () -> [String], onChange: @escaping (Bool) -> Void) {
        names = whitelist
        self.onChange = onChange

        // Observe audio route changes (connect/disconnect car BT)
        observer = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.evaluate()
        }

        try? AVAudioSession.sharedInstance().setActive(true)
        evaluate()
    }

    /// Stop monitoring and release resources.
    func stop() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        onChange = nil
        // Deactivate the session; notify others (e.g., music apps)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func evaluate() {
        // Check if any current output port name matches the whitelist
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs.map(\.portName)
        let hit = outputs.contains { out in
            names().contains { out.localizedCaseInsensitiveContains($0) }
        }
        onChange?(hit)
    }
}
