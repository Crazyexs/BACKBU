import Foundation
import Combine
import CoreLocation
import ActivityKit
import UserNotifications

@MainActor
final class AppState: ObservableObject {
    let store = Store()
    let location = LocationService()
    let settings = SettingsState()
    let zoneMonitor = SpeedZoneMonitor()

    lazy var recorder = TripRecorder(store: store, location: location, zones: zoneMonitor)

    private let motion = MotionAutoStarter()
    private let bt = BluetoothAutoStarter()

    init() {
        Task { await store.load() }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }

        location.requestPermissions()
    }

    func configureAutoStart() {
        if settings.autoStartMotion {
            motion.start { [weak self] driving in
                guard let self else { return }
                if driving, self.recorder.activeTrip == nil {
                    self.recorder.start()
                } else if !driving {
                    let minutes = self.settings.autoStopAfterMinutesStill
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(minutes * 60)) {
                        Task { await self.recorder.stopIfIdle() }
                    }
                }
            }
        } else {
            motion.stop()
        }

        if settings.autoStartBluetooth {
            bt.start(whitelist: { [weak self] in self?.settings.carBluetoothNames ?? [] }) { [weak self] connected in
                guard let self else { return }
                if connected, self.recorder.activeTrip == nil {
                    self.recorder.start()
                } else if !connected {
                    let minutes = self.settings.autoStopAfterMinutesStill
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(minutes * 60)) {
                        Task { await self.recorder.stopIfIdle() }
                    }
                }
            }
        } else {
            bt.stop()    
        }
    }
}
