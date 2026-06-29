import Foundation

protocol AppStorageProviding {
    func loadCustomProfiles() -> [CallerProfile]
    func saveCustomProfiles(_ profiles: [CallerProfile])
    func loadHistory() -> [CueHistoryItem]
    func saveHistory(_ history: [CueHistoryItem])
    func loadActiveCue() -> ScheduledCue?
    func saveActiveCue(_ cue: ScheduledCue?)
    func loadSettings() -> AppSettings
    func saveSettings(_ settings: AppSettings)
}

final class UserDefaultsStorage: AppStorageProviding {
    private enum Key {
        static let customProfiles = "exitcue.customProfiles"
        static let history = "exitcue.history"
        static let activeCue = "exitcue.activeCue"
        static let settings = "exitcue.settings"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadCustomProfiles() -> [CallerProfile] {
        load([CallerProfile].self, forKey: Key.customProfiles) ?? []
    }

    func saveCustomProfiles(_ profiles: [CallerProfile]) {
        save(profiles, forKey: Key.customProfiles)
    }

    func loadHistory() -> [CueHistoryItem] {
        load([CueHistoryItem].self, forKey: Key.history) ?? []
    }

    func saveHistory(_ history: [CueHistoryItem]) {
        save(history, forKey: Key.history)
    }

    func loadActiveCue() -> ScheduledCue? {
        load(ScheduledCue.self, forKey: Key.activeCue)
    }

    func saveActiveCue(_ cue: ScheduledCue?) {
        guard let cue else {
            defaults.removeObject(forKey: Key.activeCue)
            return
        }
        save(cue, forKey: Key.activeCue)
    }

    func loadSettings() -> AppSettings {
        load(AppSettings.self, forKey: Key.settings) ?? .defaults
    }

    func saveSettings(_ settings: AppSettings) {
        save(settings, forKey: Key.settings)
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        return try? decoder.decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}

