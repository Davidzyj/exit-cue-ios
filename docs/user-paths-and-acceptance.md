# User Paths and Acceptance Criteria

## Product boundary

Exit Cue helps users set a private timed cue that looks like a call-inspired reminder inside the app. It does not place or receive real calls, does not use CallKit, does not copy the iOS Phone app UI, and does not impersonate carriers, phone numbers, FaceTime, or third-party calling services.

## Path 1 - Start a timed exit cue

1. User opens the app on Home.
2. User selects a caller profile.
3. User selects a delay, either a quick preset or a custom minute value.
4. User taps Start.
5. Home immediately shows an active cue with the selected caller and countdown.
6. The active cue is saved locally.
7. When the timer fires in the foreground, the app presents the call-inspired cue screen.
8. User answers or dismisses.
9. The app records a local history item and returns feedback on Home.

Acceptance:
- Start is disabled until the selection is valid.
- Countdown keeps updating without requiring navigation refresh.
- Returning to Home shows the active or completed state.
- Restarting the app restores an active cue from local storage.
- Completing or canceling a cue clears active state and updates history.

## Path 2 - Immediate cue

1. User taps the quick safety action on Home.
2. App schedules a cue for immediate presentation.
3. App presents the cue screen.
4. User answers or dismisses.

Acceptance:
- The action is visible and does not require setup.
- The cue appears without fake persisted demo data.
- History reflects the result.

## Path 3 - Answer and complete a cue

1. User sees the cue screen.
2. User taps Answer.
3. App shows a simple scripted conversation screen.
4. User taps End.
5. App returns to Home with completion feedback.

Acceptance:
- The screen is clearly app-owned and not a system Phone clone.
- End records a completed result.
- Home and History refresh immediately.

## Path 4 - Manage caller profiles

1. User opens Callers.
2. User taps Add.
3. User fills name, relationship, and cue line.
4. User saves.
5. New profile appears in the list and can be selected on Home.
6. User edits or deletes custom profiles.

Acceptance:
- Input state uses focus management and keyboard dismissal.
- Save validates required fields.
- Add, edit, and delete persist locally.
- Array updates assign fresh values so SwiftUI refreshes reliably.
- Built-in profiles remain available but are not stored as screenshot demo data.

## Path 5 - Review history

1. User opens History.
2. User sees recent completed or dismissed cues.
3. User can clear history.

Acceptance:
- Empty state is explicit.
- New history appears immediately after completing a cue.
- Clear history persists locally and refreshes the UI.

## Path 6 - Settings and web links

1. User opens Settings.
2. User selects language: System, English, Simplified Chinese, or Japanese.
3. App immediately updates visible localized text.
4. User opens Privacy Policy or Support.

Acceptance:
- Explicit language choice wins over system inference.
- If unset, language is inferred from preferred languages and falls back to English.
- Settings does not show bundle ID, raw privacy URL, raw support URL, or support email.
- Links open externally to multilingual GitHub Pages.

## Path 7 - Screenshot demo mode

1. Screenshot script launches Debug build with `-ExitCueScreenshotMode YES`.
2. App uses in-memory demonstration content and selected screenshot locale.
3. Script captures 6.5-inch iPhone simulator screenshots.

Acceptance:
- Demo mode only compiles/activates in Debug.
- Release and normal launches do not initialize, show, or persist demo data.
- Demo data is not written to UserDefaults.
- Screenshots come from the real running app.

## Path 8 - App Store readability

1. App runs while the device is set to dark mode.
2. App keeps its intentionally light visual design.

Acceptance:
- UI is forced to light mode.
- Text, placeholders, disabled labels, and secondary text use explicit dark colors on light backgrounds.
- No white or pale system text appears on white, cream, or light panels.
