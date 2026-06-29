import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedTab: AppTab = AppTab.initial

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("tab.home", systemImage: "timer")
                }
                .tag(AppTab.home)

            CallersView()
                .tabItem {
                    Label("tab.callers", systemImage: "person.2")
                }
                .tag(AppTab.callers)

            HistoryView()
                .tabItem {
                    Label("tab.history", systemImage: "clock.arrow.circlepath")
                }
                .tag(AppTab.history)

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape")
                }
                .tag(AppTab.settings)
        }
        .background(ECTheme.background)
        .fullScreenCover(isPresented: $model.isCuePresented) {
            CueFlowView()
                .environmentObject(model)
                .environment(\.locale, Locale(identifier: model.effectiveLanguage.localeIdentifier))
                .preferredColorScheme(.light)
        }
        .onAppear {
            #if DEBUG
            ScreenshotMarker.write()
            #endif
        }
    }
}

enum AppTab: Hashable {
    case home
    case callers
    case history
    case settings

    static var initial: AppTab {
        #if DEBUG
        switch LaunchConfiguration.screenshotScreen {
        case "callers":
            return .callers
        case "history":
            return .history
        case "settings":
            return .settings
        default:
            return .home
        }
        #else
        return .home
        #endif
    }
}
