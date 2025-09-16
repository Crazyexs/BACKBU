import Foundation

enum AppGroup {
    /// App Group identifier pulled from Info.plist -> APP_GROUP_ID
    /// Fallback to a placeholder if not set.
    static var id: String = {
        if let v = Bundle.main.object(forInfoDictionaryKey: "APP_GROUP_ID") as? String, !v.isEmpty {
            return v
        }
        // CHANGE THIS to your actual App Group (e.g., "group.com.yourteam.backbu")
        return "group.com.yourcompany.triptracker"
    }()

    /// Shared container URL. Falls back to Documents if the App Group isn't configured yet,
    /// so the app still runs in development without crashing.
    static var containerURL: URL {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id) {
            return url
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
