import Foundation

enum AppConstants {
    static let appName = "Exit Cue"
    static let bundleID = "com.zhouyajie.exitcue"
    static let version = "1.0.0"
    static let supportEmail = "jay212315@gmail.com"
    static let privacyURL = URL(string: "https://davidzyj.github.io/exit-cue-ios/privacy/")!
    static let supportURL = URL(string: "https://davidzyj.github.io/exit-cue-ios/support/")!
}

enum LaunchConfiguration {
    static var isScreenshotMode: Bool {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        return args.contains("-ExitCueScreenshotMode") || ProcessInfo.processInfo.environment["EXIT_CUE_SCREENSHOT_MODE"] == "1"
        #else
        return false
        #endif
    }

    static var screenshotLanguage: AppLanguage? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-ExitCueScreenshotLanguage"),
              args.indices.contains(index + 1) else {
            return nil
        }
        return AppLanguage(argumentValue: args[index + 1])
        #else
        return nil
        #endif
    }

    static var screenshotScreen: String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-ExitCueScreenshotScreen"),
              args.indices.contains(index + 1) else {
            return nil
        }
        return args[index + 1].lowercased()
        #else
        return nil
        #endif
    }
}

#if DEBUG
enum ScreenshotMarker {
    static func write() {
        guard LaunchConfiguration.isScreenshotMode else {
            return
        }
        let language = LaunchConfiguration.screenshotLanguage?.webLanguageCode ?? "en"
        let screen = LaunchConfiguration.screenshotScreen ?? "home"
        let payload = """
        {"language":"\(language)","screen":"\(screen)"}
        """
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        try? payload.write(
            to: documents.appendingPathComponent("exitcue-screenshot-marker.json"),
            atomically: true,
            encoding: .utf8
        )
    }
}
#endif
