import Foundation
import UserNotifications

final class LocalNotificationService: @unchecked Sendable {
    static let shared = LocalNotificationService()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func schedule(cue: ScheduledCue, language: AppLanguage) {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle(language: language)
        content.body = cue.caller.name
        content.sound = .default
        content.userInfo = ["cueID": cue.id.uuidString]

        let interval = max(1, cue.fireAt.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: cue.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancel(cueID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [cueID.uuidString])
    }

    private func notificationTitle(language: AppLanguage) -> String {
        switch language {
        case .simplifiedChinese:
            return "离场提醒"
        case .japanese:
            return "退出リマインダー"
        case .english, .system:
            return "Exit cue"
        }
    }
}
