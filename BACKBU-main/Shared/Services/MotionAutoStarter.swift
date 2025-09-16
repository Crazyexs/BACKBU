import CoreMotion

final class MotionAutoStarter {
    private let mgr = CMMotionActivityManager()
    private var handler: ((Bool)->Void)?

    func start(handler: @escaping (Bool)->Void) {
        self.handler = handler
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        mgr.startActivityUpdates(to: .main) { act in
            guard let a = act else { return }
            let driving = a.automotive && a.confidence != .low
            handler(driving)
        }
    }
    func stop() { mgr.stopActivityUpdates() }
}
