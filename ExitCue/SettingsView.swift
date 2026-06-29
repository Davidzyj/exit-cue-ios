import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    languageSection
                    preferencesSection
                    linksSection
                    aboutSection
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .padding(.bottom, 96)
            }
            .background(ECTheme.background.ignoresSafeArea())
            .navigationTitle("settings.navTitle")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("settings.title")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(ECTheme.ink)
            Text("settings.subtitle")
                .font(.body.weight(.semibold))
                .foregroundStyle(ECTheme.muted)
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "settings.language")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(AppLanguage.allCases) { language in
                    let isSelected = model.settings.selectedLanguage == language
                    Button {
                        model.setLanguage(language)
                    } label: {
                        HStack {
                            Text(language.titleKey)
                                .font(.subheadline.weight(.heavy))
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .black))
                            }
                        }
                        .foregroundStyle(isSelected ? Color.white : ECTheme.ink)
                        .frame(height: 48)
                        .padding(.horizontal, 12)
                        .background(isSelected ? ECTheme.teal : ECTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(isSelected ? ECTheme.teal : ECTheme.line, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "settings.preferences")
            SurfaceBox {
                settingsToggle(
                    title: "settings.sound",
                    systemImage: "speaker.wave.2",
                    isOn: Binding(
                        get: { model.settings.soundEnabled },
                        set: { model.setSoundEnabled($0) }
                    )
                )
                Divider().overlay(ECTheme.line)
                settingsToggle(
                    title: "settings.haptics",
                    systemImage: "iphone.radiowaves.left.and.right",
                    isOn: Binding(
                        get: { model.settings.hapticsEnabled },
                        set: { model.setHapticsEnabled($0) }
                    )
                )
                Divider().overlay(ECTheme.line)
                settingsToggle(
                    title: "settings.notifications",
                    systemImage: "bell.badge",
                    isOn: Binding(
                        get: { model.settings.notificationsEnabled },
                        set: { value in
                            Task {
                                await model.setNotificationsEnabled(value)
                            }
                        }
                    )
                )
            }
        }
    }

    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "settings.help")
            SurfaceBox {
                linkRow(title: "settings.privacy", icon: "hand.raised") {
                    openURL(localizedURL(AppConstants.privacyURL))
                }
                Divider().overlay(ECTheme.line)
                linkRow(title: "settings.support", icon: "questionmark.circle") {
                    openURL(localizedURL(AppConstants.supportURL))
                }
            }
        }
    }

    private var aboutSection: some View {
        SurfaceBox {
            HStack {
                Label("settings.version", systemImage: "app.badge")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ECTheme.ink)
                Spacer()
                Text(AppConstants.version)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ECTheme.muted)
            }
        }
    }

    private func settingsToggle(title: LocalizedStringKey, systemImage: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(ECTheme.ink)
        }
        .tint(ECTheme.teal)
    }

    private func linkRow(title: LocalizedStringKey, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ECTheme.ink)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(ECTheme.teal)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func localizedURL(_ baseURL: URL) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "lang", value: model.effectiveLanguage.webLanguageCode)]
        return components.url ?? baseURL
    }
}
