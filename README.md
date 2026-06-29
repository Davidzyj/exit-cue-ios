# Exit Cue: Safe Timer

Exit Cue: Safe Timer is a native SwiftUI iPhone app for local timed call-style safety reminders.

It helps users set a private cue for leaving uncomfortable social situations. The app does not place or receive real phone calls, does not use CallKit, and does not require an account or backend.

## Build

```bash
xcodebuild -project ExitCue.xcodeproj -scheme ExitCue -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData build
```

## Documentation

- User paths: `docs/user-paths-and-acceptance.md`
- App Store template: `docs/app-store-connect-template.md`
- User guide: `docs/user-guide.md`
- Test cases: `docs/test-cases.md`
- Handoff: `docs/handoff.md`
