import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case system
    case english
    case simplifiedChinese
    case japanese

    var id: String { rawValue }

    var localeIdentifier: String {
        switch self {
        case .system:
            return Self.inferred.localeIdentifier
        case .english:
            return "en"
        case .simplifiedChinese:
            return "zh-Hans"
        case .japanese:
            return "ja"
        }
    }

    var webLanguageCode: String {
        switch self {
        case .system:
            return Self.inferred.webLanguageCode
        case .english:
            return "en"
        case .simplifiedChinese:
            return "zh-Hans"
        case .japanese:
            return "ja"
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .system:
            return "settings.language.system"
        case .english:
            return "settings.language.english"
        case .simplifiedChinese:
            return "settings.language.chinese"
        case .japanese:
            return "settings.language.japanese"
        }
    }

    init?(argumentValue: String) {
        switch argumentValue.lowercased() {
        case "en", "english":
            self = .english
        case "zh", "zh-hans", "chinese", "simplified-chinese":
            self = .simplifiedChinese
        case "ja", "jp", "japanese":
            self = .japanese
        case "system":
            self = .system
        default:
            return nil
        }
    }

    static var inferred: AppLanguage {
        for language in Locale.preferredLanguages {
            let normalized = language.lowercased()
            if normalized.hasPrefix("zh") {
                return .simplifiedChinese
            }
            if normalized.hasPrefix("ja") {
                return .japanese
            }
            if normalized.hasPrefix("en") {
                return .english
            }
        }
        return .english
    }
}

struct CallerProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var relationship: String
    var cueLine: String
    var accentHex: String
    var isBuiltIn: Bool

    init(
        id: UUID = UUID(),
        name: String,
        relationship: String,
        cueLine: String,
        accentHex: String,
        isBuiltIn: Bool = false
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.cueLine = cueLine
        self.accentHex = accentHex
        self.isBuiltIn = isBuiltIn
    }
}

enum CueState: String, Codable, Equatable {
    case scheduled
    case ringing
    case answered
}

struct ScheduledCue: Identifiable, Codable, Equatable {
    var id: UUID
    var caller: CallerProfile
    var createdAt: Date
    var fireAt: Date
    var delaySeconds: Int
    var state: CueState

    var remainingSeconds: Int {
        max(0, Int(ceil(fireAt.timeIntervalSinceNow)))
    }
}

enum CueResult: String, Codable, Equatable {
    case completed
    case dismissed
    case cancelled
}

struct CueHistoryItem: Identifiable, Codable, Equatable {
    var id: UUID
    var callerName: String
    var relationship: String
    var date: Date
    var result: CueResult
    var delaySeconds: Int
}

struct AppSettings: Codable, Equatable {
    var selectedLanguage: AppLanguage
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var notificationsEnabled: Bool

    static let defaults = AppSettings(
        selectedLanguage: .system,
        hapticsEnabled: true,
        soundEnabled: true,
        notificationsEnabled: false
    )
}

