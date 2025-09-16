# BACKBU — Fixes & Setup Guide

This repository contained an iOS app with Widgets and Live Activities. I made the following fixes and improvements to help you build and run it reliably:

## ✅ Key Fixes

1. **App Group configuration made explicit and safe**
   - `Shared/Helpers/AppGroup.swift` now reads `APP_GROUP_ID` from **Info.plist** (`APP_GROUP_ID`).
   - If the App Group is not configured yet, it **falls back** to the app's Documents directory to avoid crashes in development.
   - Add your real App Group (e.g., `group.com.yourteam.backbu`) to **all targets** that need shared storage: the main app, widget extension(s), and live activity extension.

2. **Project hygiene**
   - A `/Config/AppConfig.xcconfig` file was added to help you manage the `APP_GROUP_ID` in one place (optional). See comments inside the file.

## 🧩 Where your data is stored

The app and widgets read/write JSON under:
```
AppGroup.containerURL / "data/"
  - trips.json
  - speed_sections.json
  - speed_zones.json
```
If the App Group is not yet available, it falls back to the app's **Documents** folder, so the app stays functional while you sort out signing.

## 🔧 What you must do in Xcode

1. **Set the App Group** in *Signing & Capabilities* for each target (App, Widgets, Live Activity):
   - Add capability **App Groups** → press `+` → create/select your group (e.g., `group.com.yourteam.backbu`).

2. **Expose the App Group to code**
   - In each target's **Info** tab (or Info.plist), add:
     - Key: `APP_GROUP_ID` (String)
     - Value: `group.com.yourteam.backbu` (your real group)
   - Alternatively, set it via `Config/AppConfig.xcconfig` and ensure the configuration is applied.

3. **Live Activities (iOS 16.1+)**
   - Ensure the extension target includes **ActivityKit** and is provisioned correctly.
   - On device, enable **Allow Live Activities** in Settings if needed.

## 🐞 Common build/runtime issues addressed

- **Crash on widget timeline building due to missing container URL** — now prevented by a safe fallback in `AppGroup`.
- **Widgets not seeing app data** — make sure *all* related targets share the **same** App Group ID and the files exist under `data/` as listed above.
- **Week calculations** — uses `Calendar.current` week-of-year; if you prefer ISO weeks, set `calendar.firstWeekday = 2` or use `calendar = Calendar(identifier: .iso8601)` in your provider.

## 📁 Notable files you might want to check

- `Shared/Services/Store.swift` — loads/saves `trips.json`, `speed_sections.json`, `speed_zones.json` in the shared container.
- `LastTripWidget.swift` and `WeekWidget.swift` — read from `AppGroup.containerURL` and refresh every ~30 minutes.
- `LastActivity/TripActivityAttributes.swift` — Live Activity content state.

## 🧪 Quick manual test

- Run the app on a device/simulator after setting `APP_GROUP_ID`.
- Add a few dummy `Trip` items in the app and confirm that `data/trips.json` is created in the shared container.
- Add the **Last Trip** and **This Week** widgets on the Home Screen and verify values update after ~30 minutes or via WidgetKit reload.

---

If you want me to also re-organize the Xcode project structure (e.g., nested `BACKBU-main/BACKBU-main` folders, target files, schemes), let me know and I’ll produce an `.xcodeproj/.xcworkspace` layout with a clean group hierarchy.
