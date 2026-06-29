import Foundation

enum BuiltInContent {
    private static let familyID = UUID(uuidString: "EA84A4B9-0D1D-4B54-AFF1-5AB71CC8AC01")!
    private static let friendID = UUID(uuidString: "B61224D3-8358-42E9-96B7-59366D6F8E81")!
    private static let officeID = UUID(uuidString: "5FA05053-C510-4DAD-A487-84B0C5D3B2E8")!

    static func profiles(language: AppLanguage) -> [CallerProfile] {
        switch language {
        case .simplifiedChinese:
            return [
                CallerProfile(id: familyID, name: "家人", relationship: "需要你回个电话", cueLine: "现在方便回来一下吗？", accentHex: "#E05F5F", isBuiltIn: true),
                CallerProfile(id: friendID, name: "朋友", relationship: "临时有事找你", cueLine: "我这边有点急事，需要你帮忙。", accentHex: "#326D80", isBuiltIn: true),
                CallerProfile(id: officeID, name: "同事", relationship: "工作事项提醒", cueLine: "刚刚那件事需要你确认一下。", accentHex: "#7A6A2E", isBuiltIn: true)
            ]
        case .japanese:
            return [
                CallerProfile(id: familyID, name: "家族", relationship: "折り返しが必要", cueLine: "今、戻ってこられる？", accentHex: "#E05F5F", isBuiltIn: true),
                CallerProfile(id: friendID, name: "友人", relationship: "少し急ぎの用件", cueLine: "ちょっと助けてほしいことがある。", accentHex: "#326D80", isBuiltIn: true),
                CallerProfile(id: officeID, name: "同僚", relationship: "仕事の確認", cueLine: "さっきの件、確認してもらえる？", accentHex: "#7A6A2E", isBuiltIn: true)
            ]
        case .english, .system:
            return [
                CallerProfile(id: familyID, name: "Family", relationship: "Needs a call back", cueLine: "Can you come back for a moment?", accentHex: "#E05F5F", isBuiltIn: true),
                CallerProfile(id: friendID, name: "Friend", relationship: "Needs quick help", cueLine: "I need your help with something urgent.", accentHex: "#326D80", isBuiltIn: true),
                CallerProfile(id: officeID, name: "Colleague", relationship: "Work check-in", cueLine: "Can you confirm that item for me?", accentHex: "#7A6A2E", isBuiltIn: true)
            ]
        }
    }
}

#if DEBUG
enum DemoContent {
    static let customProfiles: [CallerProfile] = [
        CallerProfile(
            id: UUID(uuidString: "2CE5994A-0DF0-4C1A-9A6D-4140782D6A22")!,
            name: "Mina",
            relationship: "Safety buddy",
            cueLine: "I am outside. Come meet me when you can.",
            accentHex: "#B76E79"
        )
    ]

    static func activeCue(language: AppLanguage) -> ScheduledCue {
        let caller = BuiltInContent.profiles(language: language).first!
        return ScheduledCue(
            id: UUID(uuidString: "CA8467C8-F9F5-4AB7-9A3A-0184301BE3D6")!,
            caller: caller,
            createdAt: Date().addingTimeInterval(-90),
            fireAt: Date().addingTimeInterval(240),
            delaySeconds: 300,
            state: .scheduled
        )
    }

    static let history: [CueHistoryItem] = [
        CueHistoryItem(
            id: UUID(uuidString: "13BC4664-A0CE-47BD-887F-75BD9D281656")!,
            callerName: "Family",
            relationship: "Needs a call back",
            date: Date().addingTimeInterval(-3600),
            result: .completed,
            delaySeconds: 300
        ),
        CueHistoryItem(
            id: UUID(uuidString: "CC1498EA-F209-464E-8CD0-8012C92A8EE5")!,
            callerName: "Friend",
            relationship: "Needs quick help",
            date: Date().addingTimeInterval(-86400),
            result: .cancelled,
            delaySeconds: 600
        )
    ]
}
#endif

