import SwiftUI

@main
struct ExitCueApp: App {
    @StateObject private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .environment(\.locale, Locale(identifier: model.effectiveLanguage.localeIdentifier))
                .preferredColorScheme(.light)
                .tint(ECTheme.teal)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        model.evaluateActiveCue()
                    }
                }
        }
    }
}

