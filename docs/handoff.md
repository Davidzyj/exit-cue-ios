# Handoff

## Project summary

Exit Cue: Safe Timer is a native SwiftUI iPhone app for local timed call-style safety reminders. It is intentionally framed as a safe exit reminder, not a fake phone call utility.

## Key identifiers

- Xcode project: `ExitCue.xcodeproj`
- Scheme: `ExitCue`
- Bundle ID: `com.zhouyajie.exitcue`
- Version: `1.0.0`
- Minimum iOS: 17.0
- Device family: iPhone only
- App icon: `ExitCue/Assets.xcassets/AppIcon.appiconset/Icon-1024.png`
- Info.plist: `ExitCue/Info.plist`

## Important implementation notes

- State lives in `AppModel`.
- Production persistence uses `UserDefaultsStorage`.
- Demo screenshot mode is gated by `#if DEBUG` and `-ExitCueScreenshotMode YES`.
- Release builds cannot activate screenshot demo data through launch arguments.
- Custom profile arrays and history arrays are reassigned after changes to trigger SwiftUI refresh.
- The app does not use CallKit or make real phone calls.
- Optional reminders use local notifications only after the user enables notifications.
- UI is forced to light mode through `UIUserInterfaceStyle = Light` and `.preferredColorScheme(.light)`.
- Text colors are explicit in the custom light theme.

## Main files

- `ExitCue/AppModel.swift`: scheduling, cue state, persistence, history, settings.
- `ExitCue/Models.swift`: app data models and language inference.
- `ExitCue/BuiltInContent.swift`: built-in caller templates and Debug-only demo content.
- `ExitCue/HomeView.swift`: start, active cue, caller and delay selection.
- `ExitCue/CallerViews.swift`: add/edit/delete custom caller profiles.
- `ExitCue/CueFlowView.swift`: ringing and conversation screens.
- `ExitCue/SettingsView.swift`: language, toggles, privacy/support links.
- `ExitCue/*.lproj`: localized app strings and display names.
- `docs/app-store-connect-template.md`: copy-ready App Store fields.
- `scripts/capture_screenshots.sh`: real simulator screenshot capture.

## Build commands

```bash
xcodebuild -project ExitCue.xcodeproj -scheme ExitCue -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData build
plutil -lint ExitCue/Info.plist
xcodebuild -project ExitCue.xcodeproj -scheme ExitCue -showBuildSettings | rg 'INFOPLIST_FILE|PRODUCT_BUNDLE_IDENTIFIER|MARKETING_VERSION|TARGETED_DEVICE_FAMILY'
```

## Screenshot command

```bash
scripts/capture_screenshots.sh
```

The script targets a 6.5-inch iPhone-compatible simulator and launches the app with explicit screenshot arguments.

It creates three language folders:
- `screenshots/iphone-6.5/en/`
- `screenshots/iphone-6.5/zh-Hans/`
- `screenshots/iphone-6.5/ja/`

Contact sheets are written to `build/screenshot-previews/`.

## GitHub Pages

The public pages are in `docs/`:
- `docs/index.html`
- `docs/privacy/index.html`
- `docs/support/index.html`

Configure GitHub Pages to serve from the `docs/` folder on `main`.

Expected URLs:
- `https://davidzyj.github.io/exit-cue-ios/privacy/`
- `https://davidzyj.github.io/exit-cue-ios/support/`

## Remaining owner actions

- Confirm legal copyright holder.
- Set Apple Developer Team signing.
- Create App Store Connect app record.
- Upload Release archive.
- Add final screenshots per localization.
- Complete App Privacy, age rating, pricing, and availability.
