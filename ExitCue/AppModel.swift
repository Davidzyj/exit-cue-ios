import AudioToolbox
import Foundation
import SwiftUI
import UIKit

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var customProfiles: [CallerProfile] = []
    @Published private(set) var history: [CueHistoryItem] = []
    @Published private(set) var activeCue: ScheduledCue?
    @Published var settings: AppSettings
    @Published var selectedProfileID: UUID?
    @Published var selectedDelaySeconds: Int = 300
    @Published var customDelayMinutes: Int = 12
    @Published var isCuePresented = false
    @Published var now = Date()
    @Published var feedbackKey: LocalizedStringKey?

    let isDemoMode: Bool

    private let storage: AppStorageProviding
    private let notificationService: LocalNotificationService
    private var timer: Timer?

    var effectiveLanguage: AppLanguage {
        if settings.selectedLanguage == .system {
            return AppLanguage.inferred
        }
        return settings.selectedLanguage
    }

    var allProfiles: [CallerProfile] {
        BuiltInContent.profiles(language: effectiveLanguage) + customProfiles
    }

    var selectedProfile: CallerProfile? {
        allProfiles.first { $0.id == selectedProfileID } ?? allProfiles.first
    }

    var canStartCue: Bool {
        selectedProfile != nil && selectedDelaySeconds >= 0
    }

    init(
        storage: AppStorageProviding = UserDefaultsStorage(),
        notificationService: LocalNotificationService = .shared,
        isDemoMode: Bool = LaunchConfiguration.isScreenshotMode
    ) {
        self.storage = storage
        self.notificationService = notificationService
        self.isDemoMode = isDemoMode

        #if DEBUG
        if isDemoMode {
            var demoSettings = AppSettings.defaults
            if let launchLanguage = LaunchConfiguration.screenshotLanguage {
                demoSettings.selectedLanguage = launchLanguage
            } else {
                demoSettings.selectedLanguage = .english
            }
            self.settings = demoSettings
            self.customProfiles = DemoContent.customProfiles
            self.history = DemoContent.history
            self.activeCue = DemoContent.activeCue(language: demoSettings.selectedLanguage)
            if LaunchConfiguration.screenshotScreen == "ringing" {
                self.activeCue?.state = .ringing
                self.isCuePresented = true
            }
        } else {
            self.settings = storage.loadSettings()
            self.customProfiles = storage.loadCustomProfiles()
            self.history = storage.loadHistory()
            self.activeCue = storage.loadActiveCue()
        }
        #else
        self.settings = storage.loadSettings()
        self.customProfiles = storage.loadCustomProfiles()
        self.history = storage.loadHistory()
        self.activeCue = storage.loadActiveCue()
        #endif

        selectedProfileID = allProfiles.first?.id
        startTimer()
        evaluateActiveCue()
    }

    func setLanguage(_ language: AppLanguage) {
        settings.selectedLanguage = language
        persistSettings()
        if selectedProfileID == nil {
            selectedProfileID = allProfiles.first?.id
        }
    }

    func setSoundEnabled(_ isEnabled: Bool) {
        settings.soundEnabled = isEnabled
        persistSettings()
    }

    func setHapticsEnabled(_ isEnabled: Bool) {
        settings.hapticsEnabled = isEnabled
        persistSettings()
    }

    func setNotificationsEnabled(_ isEnabled: Bool) async {
        if isEnabled {
            let granted = await notificationService.requestAuthorization()
            settings.notificationsEnabled = granted
            if granted, let activeCue {
                notificationService.schedule(cue: activeCue, language: effectiveLanguage)
            }
        } else {
            if let activeCue {
                notificationService.cancel(cueID: activeCue.id)
            }
            settings.notificationsEnabled = false
        }
        persistSettings()
    }

    func chooseProfile(_ profile: CallerProfile) {
        selectedProfileID = profile.id
    }

    func chooseDelay(seconds: Int) {
        selectedDelaySeconds = seconds
    }

    func useCustomDelay() {
        selectedDelaySeconds = max(1, customDelayMinutes) * 60
    }

    func startSelectedCue() {
        startCue(delaySeconds: selectedDelaySeconds)
    }

    func startImmediateCue() {
        startCue(delaySeconds: 0)
    }

    func startCue(delaySeconds: Int) {
        guard let profile = selectedProfile else {
            return
        }

        let fireAt = Date().addingTimeInterval(TimeInterval(delaySeconds))
        let cue = ScheduledCue(
            id: UUID(),
            caller: profile,
            createdAt: Date(),
            fireAt: fireAt,
            delaySeconds: delaySeconds,
            state: delaySeconds == 0 ? .ringing : .scheduled
        )
        activeCue = cue
        feedbackKey = "home.feedback.started"
        persistActiveCue()

        if settings.notificationsEnabled {
            notificationService.schedule(cue: cue, language: effectiveLanguage)
        }

        if delaySeconds == 0 {
            presentCue()
        }
    }

    func previewActiveCue() {
        guard activeCue != nil else {
            return
        }
        markActiveCueRinging()
        presentCue()
    }

    func cancelActiveCue() {
        guard let cue = activeCue else {
            return
        }
        notificationService.cancel(cueID: cue.id)
        addHistory(for: cue, result: .cancelled)
        activeCue = nil
        isCuePresented = false
        feedbackKey = "home.feedback.cancelled"
        persistActiveCue()
    }

    func answerCue() {
        guard var cue = activeCue else {
            return
        }
        cue.state = .answered
        activeCue = cue
        feedback()
        persistActiveCue()
    }

    func dismissCue() {
        guard let cue = activeCue else {
            isCuePresented = false
            return
        }
        addHistory(for: cue, result: .dismissed)
        notificationService.cancel(cueID: cue.id)
        activeCue = nil
        isCuePresented = false
        feedbackKey = "home.feedback.dismissed"
        persistActiveCue()
    }

    func completeCue() {
        guard let cue = activeCue else {
            isCuePresented = false
            return
        }
        addHistory(for: cue, result: .completed)
        notificationService.cancel(cueID: cue.id)
        activeCue = nil
        isCuePresented = false
        feedbackKey = "home.feedback.completed"
        persistActiveCue()
    }

    func scheduleFollowUp(minutes: Int) {
        startCue(delaySeconds: max(1, minutes) * 60)
        isCuePresented = false
    }

    func addProfile(name: String, relationship: String, cueLine: String, accentHex: String) {
        let profile = CallerProfile(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            relationship: relationship.trimmingCharacters(in: .whitespacesAndNewlines),
            cueLine: cueLine.trimmingCharacters(in: .whitespacesAndNewlines),
            accentHex: accentHex
        )
        customProfiles = customProfiles + [profile]
        selectedProfileID = profile.id
        persistCustomProfiles()
    }

    func updateProfile(_ profile: CallerProfile) {
        guard !profile.isBuiltIn else {
            return
        }
        let trimmed = CallerProfile(
            id: profile.id,
            name: profile.name.trimmingCharacters(in: .whitespacesAndNewlines),
            relationship: profile.relationship.trimmingCharacters(in: .whitespacesAndNewlines),
            cueLine: profile.cueLine.trimmingCharacters(in: .whitespacesAndNewlines),
            accentHex: profile.accentHex,
            isBuiltIn: false
        )
        customProfiles = customProfiles.map { $0.id == trimmed.id ? trimmed : $0 }
        persistCustomProfiles()
    }

    func deleteProfile(_ profile: CallerProfile) {
        guard !profile.isBuiltIn else {
            return
        }
        customProfiles = customProfiles.filter { $0.id != profile.id }
        if selectedProfileID == profile.id {
            selectedProfileID = allProfiles.first?.id
        }
        persistCustomProfiles()
    }

    func clearHistory() {
        history = []
        persistHistory()
    }

    func evaluateActiveCue() {
        now = Date()
        guard let cue = activeCue else {
            return
        }
        if cue.fireAt <= now && cue.state == .scheduled {
            markActiveCueRinging()
            presentCue()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.evaluateActiveCue()
            }
        }
    }

    private func presentCue() {
        feedback()
        isCuePresented = true
    }

    private func markActiveCueRinging() {
        guard var cue = activeCue else {
            return
        }
        cue.state = .ringing
        activeCue = cue
        persistActiveCue()
    }

    private func addHistory(for cue: ScheduledCue, result: CueResult) {
        let item = CueHistoryItem(
            id: UUID(),
            callerName: cue.caller.name,
            relationship: cue.caller.relationship,
            date: Date(),
            result: result,
            delaySeconds: cue.delaySeconds
        )
        history = [item] + history.prefix(24)
        persistHistory()
    }

    private func feedback() {
        if settings.hapticsEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        if settings.soundEnabled {
            AudioServicesPlaySystemSound(1007)
        }
    }

    private func persistCustomProfiles() {
        guard !isDemoMode else {
            return
        }
        storage.saveCustomProfiles(customProfiles)
    }

    private func persistHistory() {
        guard !isDemoMode else {
            return
        }
        storage.saveHistory(history)
    }

    private func persistActiveCue() {
        guard !isDemoMode else {
            return
        }
        storage.saveActiveCue(activeCue)
    }

    private func persistSettings() {
        guard !isDemoMode else {
            return
        }
        storage.saveSettings(settings)
    }
}
