# Test Cases

## Build and configuration

1. Build Debug for iOS Simulator.
   - Expected: `xcodebuild` succeeds.
2. Lint `ExitCue/Info.plist`.
   - Expected: `plutil` reports OK.
3. Confirm target Info.plist.
   - Expected: `xcodebuild -showBuildSettings` shows `INFOPLIST_FILE = ExitCue/Info.plist`.
4. Confirm export compliance.
   - Expected: `ITSAppUsesNonExemptEncryption` is boolean `false`.
5. Confirm iPhone-only support.
   - Expected: `UIDeviceFamily` contains only `1`; target build setting `TARGETED_DEVICE_FAMILY = 1`.

## Core user paths

1. Start a 5-minute cue from Home.
   - Expected: Active cue appears with countdown and persists after app restart.
2. Start an immediate cue.
   - Expected: Cue screen appears immediately.
3. Answer a cue.
   - Expected: Conversation screen appears; End records a completed history item.
4. Dismiss a cue.
   - Expected: Cue closes and History shows dismissed.
5. Cancel an active cue from Home.
   - Expected: Active cue clears and History shows canceled.
6. Schedule a follow-up from the conversation screen.
   - Expected: Cue closes and Home shows a new active 5-minute countdown.

## Caller management

1. Add a custom caller with valid fields.
   - Expected: New caller appears, becomes selectable, and persists after restart.
2. Attempt to save with an empty required field.
   - Expected: Save button is disabled with readable disabled text.
3. Edit a custom caller.
   - Expected: List updates immediately and persists.
4. Delete a custom caller.
   - Expected: Confirmation appears; list updates after delete; selected profile falls back to an available profile.
5. Try to edit built-in profiles.
   - Expected: Built-in profiles are selectable but not editable or deletable.

## Localization

1. Select English, Simplified Chinese, and Japanese in Settings.
   - Expected: Visible app text updates immediately.
2. Select System.
   - Expected: App infers from preferred languages and falls back to English.
3. Check CFBundleDisplayName localizations.
   - Expected: `Exit Cue: Safe Timer`, `安心离场`, and `安心エグジット` exist in `InfoPlist.strings`.

## Readability and dark mode

1. Set simulator appearance to dark.
   - Expected: App remains in light mode.
2. Review Home, Callers, History, Settings, and cue screens.
   - Expected: Text, placeholders, disabled labels, and secondary copy stay dark enough on light backgrounds.

## Screenshot demo mode

1. Launch Debug with `-ExitCueScreenshotMode YES`.
   - Expected: Demo content appears in memory only.
2. Launch Release or normal Debug without the argument.
   - Expected: No demo active cue or demo history is initialized.
3. Capture screenshots with `scripts/capture_screenshots.sh`.
   - Expected: Real simulator screenshots are created under `screenshots/iphone-6.5/en/`, `screenshots/iphone-6.5/zh-Hans/`, and `screenshots/iphone-6.5/ja/`.

## Privacy and settings links

1. Open Settings.
   - Expected: Privacy and Support entries appear without showing URLs or email addresses.
2. Tap Privacy Policy.
   - Expected: Browser opens the multilingual privacy page.
3. Tap Support.
   - Expected: Browser opens the multilingual support page.
