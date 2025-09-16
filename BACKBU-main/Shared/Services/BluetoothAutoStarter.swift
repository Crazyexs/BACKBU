import AVFAudio
import Foundation

final class BluetoothAutoStarter {
    private var names: () -> [String] = { [] }
    private var onChange: ((Bool) -> Void)?
    private var observer: NSObjectProtocol?

    func start(whitelist: @escaping () -> [String], onChange: @escaping (Bool) -> Void) {
        names = whitelist
        self.onChange = onChange

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

    func stop() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        onChange = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func evaluate() {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs.map(\.portName)
        let hit = outputs.contains { out in
            names().contains { out.localizedCaseInsensitiveContains($0) }
        }
        onChange?(hit)
    }
}
