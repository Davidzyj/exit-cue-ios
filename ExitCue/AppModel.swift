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
    @Published var isCueAlertMuted = false

    let isDemoMode: Bool

    private let storage: AppStorageProviding
    private let notificationService: LocalNotificationService
    private let cueAlertLoop = CueAlertLoop()
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
        refreshCueAlertLoop()
    }

    func setHapticsEnabled(_ isEnabled: Bool) {
        settings.hapticsEnabled = isEnabled
        persistSettings()
        refreshCueAlertLoop()
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
        stopCueAlertLoop()
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
        stopCueAlertLoop()
        cue.state = .answered
        activeCue = cue
        confirmationFeedback()
        persistActiveCue()
    }

    func dismissCue() {
        guard let cue = activeCue else {
            stopCueAlertLoop()
            isCuePresented = false
            return
        }
        stopCueAlertLoop()
        addHistory(for: cue, result: .dismissed)
        notificationService.cancel(cueID: cue.id)
        activeCue = nil
        isCuePresented = false
        feedbackKey = "home.feedback.dismissed"
        persistActiveCue()
    }

    func completeCue() {
        guard let cue = activeCue else {
            stopCueAlertLoop()
            isCuePresented = false
            return
        }
        stopCueAlertLoop()
        addHistory(for: cue, result: .completed)
        notificationService.cancel(cueID: cue.id)
        activeCue = nil
        isCuePresented = false
        feedbackKey = "home.feedback.completed"
        persistActiveCue()
    }

    func scheduleFollowUp(minutes: Int) {
        stopCueAlertLoop()
        startCue(delaySeconds: max(1, minutes) * 60)
        isCuePresented = false
    }

    func toggleCueAlertMute() {
        isCueAlertMuted.toggle()
        refreshCueAlertLoop()
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
        isCueAlertMuted = false
        isCuePresented = true
        refreshCueAlertLoop()
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

    private func refreshCueAlertLoop() {
        guard isCuePresented, activeCue?.state == .ringing, !isCueAlertMuted else {
            cueAlertLoop.stop()
            return
        }
        cueAlertLoop.start(soundEnabled: settings.soundEnabled, hapticsEnabled: settings.hapticsEnabled)
    }

    private func stopCueAlertLoop() {
        cueAlertLoop.stop()
        isCueAlertMuted = false
    }

    private func confirmationFeedback() {
        if settings.hapticsEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
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

@MainActor
final class CueAlertLoop {
    private var soundTimer: Timer?
    private var hapticTimer: Timer?
    private var soundID: SystemSoundID?

    func start(soundEnabled: Bool, hapticsEnabled: Bool) {
        stop()

        if soundEnabled {
            prepareSoundIfNeeded()
            playSound()
            soundTimer = Timer.scheduledTimer(withTimeInterval: 2.6, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.playSound()
                }
            }
        }

        if hapticsEnabled {
            playHapticPulse()
            hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.playHapticPulse()
                }
            }
        }
    }

    func stop() {
        soundTimer?.invalidate()
        soundTimer = nil
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    private func prepareSoundIfNeeded() {
        guard soundID == nil, let url = ringToneURL() else {
            return
        }
        var newSoundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &newSoundID)
        if status == kAudioServicesNoError {
            soundID = newSoundID
        }
    }

    private func playSound() {
        guard let soundID else {
            return
        }
        AudioServicesPlaySystemSound(soundID)
    }

    private func playHapticPulse() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    private func ringToneURL() -> URL? {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        let url = cacheURL.appendingPathComponent("exitcue-soft-ring.wav")
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }

        do {
            try makeRingToneData().write(to: url, options: [.atomic])
            return url
        } catch {
            return nil
        }
    }

    private func makeRingToneData() -> Data {
        let sampleRate = 44_100
        let duration = 1.18
        let frameCount = Int(Double(sampleRate) * duration)
        var pcm = Data()
        pcm.reserveCapacity(frameCount * 2)

        for frame in 0..<frameCount {
            let time = Double(frame) / Double(sampleRate)
            let frequency: Double?

            if time < 0.30 {
                frequency = 880
            } else if time < 0.43 {
                frequency = nil
            } else if time < 0.73 {
                frequency = 660
            } else {
                frequency = nil
            }

            let sample: Int16
            if let frequency {
                let edgeFade = 0.018
                let localTime = time < 0.30 ? time : time - 0.43
                let toneDuration = time < 0.30 ? 0.30 : 0.30
                let attack = min(1, localTime / edgeFade)
                let release = min(1, max(0, (toneDuration - localTime) / edgeFade))
                let envelope = max(0, min(attack, release))
                let wave = sin(2 * Double.pi * frequency * time)
                sample = Int16(max(-1, min(1, wave * envelope * 0.32)) * Double(Int16.max))
            } else {
                sample = 0
            }
            pcm.appendLittleEndian(sample)
        }

        var data = Data()
        data.append("RIFF".data(using: .ascii)!)
        data.appendLittleEndian(UInt32(36 + pcm.count))
        data.append("WAVE".data(using: .ascii)!)
        data.append("fmt ".data(using: .ascii)!)
        data.appendLittleEndian(UInt32(16))
        data.appendLittleEndian(UInt16(1))
        data.appendLittleEndian(UInt16(1))
        data.appendLittleEndian(UInt32(sampleRate))
        data.appendLittleEndian(UInt32(sampleRate * 2))
        data.appendLittleEndian(UInt16(2))
        data.appendLittleEndian(UInt16(16))
        data.append("data".data(using: .ascii)!)
        data.appendLittleEndian(UInt32(pcm.count))
        data.append(pcm)
        return data
    }
}

private extension Data {
    mutating func appendLittleEndian<T: FixedWidthInteger>(_ value: T) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { bytes in
            append(contentsOf: bytes)
        }
    }
}
