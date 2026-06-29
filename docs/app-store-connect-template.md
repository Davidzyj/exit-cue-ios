# App Store Connect Template

## App Record

- App name: Exit Cue: Safe Timer
- Chinese display name: 安心离场
- Japanese display name: 安心エグジット
- Bundle ID: `com.zhouyajie.exitcue`
- SKU: `exitcue-ios-100`
- Version: `1.0.0`
- Platform: iOS
- Device support: iPhone only
- Primary language: English
- Primary category: Lifestyle
- Secondary category: Utilities
- Pricing: Free
- Support email: `jay212315@gmail.com`
- Privacy Policy URL: `https://davidzyj.github.io/exit-cue-ios/privacy/`
- Support URL: `https://davidzyj.github.io/exit-cue-ios/support/`
- Copyright: Owner to confirm legal name in Apple Developer account.

## English Listing

Name:
Exit Cue: Safe Timer

Subtitle:
Timed reminders for safe exits

Promotional text:
Set a private call-style cue for uncomfortable social moments.

Description:
Exit Cue: Safe Timer helps you create a discreet timed reminder when you may need a calm way to leave a date, meeting, or social situation.

Choose a caller profile, pick a delay, and start a local cue. When the timer fires, Exit Cue: Safe Timer presents a call-inspired screen inside the app. You can answer, dismiss, mark yourself safe, or schedule a short follow-up.

The app is local-first: no account, no backend, no analytics, no ads, and no tracking. Caller profiles, history, and preferences stay on your device.

Exit Cue: Safe Timer does not place or receive real phone calls, does not use CallKit, and does not impersonate the iOS Phone app.

Keywords:
safety,reminder,exit,date,meeting,timer,local,private,call,cue

## Simplified Chinese Listing

名称:
安心离场

副标题:
私密定时离场提醒

推广文本:
为相亲、聚会、会议等场景设置一个本地来电风格提醒。

描述:
安心离场帮助你在不舒服的社交场景里，给自己设置一个从容离开的私密提醒。

选择联系人身份，设置延时，然后开始本地提醒。到点后，App 会显示一个来电风格的提醒界面。你可以接听、挂断、标记安全，或设置 5 分钟后的再次提醒。

安心离场优先保护本地隐私：不需要账号，不连接后端，不使用分析、广告或追踪。联系人资料、历史记录和偏好设置都只保存在你的设备上。

本 App 不会拨打或接收真实电话，不使用 CallKit，也不会冒充 iOS 电话 App。

关键词:
安全,脱身,离场,提醒,相亲,会议,计时器,本地,隐私,来电

## Japanese Listing

Name:
安心エグジット

Subtitle:
安全な退出のためのタイマー

Promotional text:
気まずい場面から落ち着いて離れるための通話風リマインダー。

Description:
安心エグジットは、デート、会議、集まりなどで落ち着いて離れたい時に使えるプライベートなタイマーリマインダーです。

相手プロフィールを選び、遅延時間を設定して開始します。時間になると、アプリ内に通話風の合図画面が表示されます。応答、閉じる、安全として記録、または 5 分後の再通知を選べます。

このアプリはローカル優先です。アカウント、バックエンド、分析、広告、トラッキングはありません。プロフィール、履歴、設定は端末内に保存されます。

安心エグジットは実際の通話を発信・受信せず、CallKit を使用せず、iOS の電話アプリを模倣しません。

Keywords:
安全,退出,リマインダー,タイマー,デート,会議,ローカル,プライバシー,通話

## App Privacy

- Data collected: No data collected.
- Tracking: No.
- Accounts: No account creation or sign-in.
- Analytics: None.
- Advertising: None.
- Third-party SDKs: None.
- Network: The app does not actively request network resources. Settings links open the privacy and support pages only when the user taps them.
- Local storage: Caller profiles, history, active cue, and preferences are stored in UserDefaults on device.
- Notifications: Optional local notifications only, requested when the user enables the setting.

## Review Information

Demo account:
Not required. The app has no account system.

Review notes:
This app provides local scheduled safety reminders with a call-inspired interface to help users exit uncomfortable social situations. It does not place or receive real calls, does not use CallKit, does not impersonate the iOS Phone app, and all user-created content is stored locally on device. The screenshot/demo data mode is Debug-only and requires explicit launch arguments; it is not active in Release builds.

Contact:
- First name: Owner to fill
- Last name: Owner to fill
- Phone: Owner to fill
- Email: `jay212315@gmail.com`

## Compliance

- Export compliance: `ITSAppUsesNonExemptEncryption = false`.
- Non-exempt encryption: No.
- In-app purchases/subscriptions: No.
- User-generated public content: No.
- Web browsing: No unrestricted in-app browsing.
- Health, medical, financial, or location data: None.
- CallKit: Not used.
- Push notifications: Not used. The app may request local notification permission only when the user enables reminders.

## Age Rating Draft

Expected age rating: 4+.

Suggested answers:
- Cartoon/fantasy violence: None
- Realistic violence: None
- Sexual content/nudity: None
- Profanity: None
- Alcohol/tobacco/drugs: None
- Medical/treatment information: None
- Gambling: None
- Unrestricted web access: No
- User-generated content: No

## Screenshots and Icon

- App icon: `ExitCue/Assets.xcassets/AppIcon.appiconset/Icon-1024.png`
- Screenshot script: `scripts/capture_screenshots.sh`
- Screenshot output directories:
  - `screenshots/iphone-6.5/en/`
  - `screenshots/iphone-6.5/zh-Hans/`
  - `screenshots/iphone-6.5/ja/`
- Required screenshot data mode: `-ExitCueScreenshotMode YES`
- Required screenshot simulator: 6.5-inch iPhone-compatible simulator.

## Owner Manual Steps

- Confirm the legal copyright holder name.
- Add Apple Developer Team signing in Xcode.
- Create the App Store Connect app record with `com.zhouyajie.exitcue`.
- Enable GitHub Pages for the repository from the `docs/` folder on the `main` branch.
- Verify Privacy Policy and Support URLs are public.
- Archive a Release build in Xcode and upload with Organizer or Transporter.
- Add screenshots in App Store Connect for each localization.
- Complete final age rating, pricing, availability, and release options.
