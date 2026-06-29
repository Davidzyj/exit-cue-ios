import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var model: AppModel

    private let quickDelays: [(LocalizedStringKey, Int, String)] = [
        ("delay.now", 0, "bolt.fill"),
        ("delay.oneMinute", 60, "1.circle.fill"),
        ("delay.fiveMinutes", 300, "5.circle.fill"),
        ("delay.tenMinutes", 600, "10.circle.fill")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if let feedbackKey = model.feedbackKey {
                        feedbackBanner(feedbackKey)
                    }
                    if let activeCue = model.activeCue {
                        activeCueBox(activeCue)
                    }
                    startBox
                    callerPicker
                    delayPicker
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .padding(.bottom, 96)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(ECTheme.background.ignoresSafeArea())
            .navigationTitle("home.navTitle")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("home-screen")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            IconPill(systemName: "shield.lefthalf.filled", title: "home.eyebrow", color: ECTheme.teal)
            Text("home.title")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(ECTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("home.subtitle")
                .font(.body.weight(.semibold))
                .foregroundStyle(ECTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }

    private var startBox: some View {
        SurfaceBox {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(ECTheme.softCoral)
                    Image(systemName: "phone.badge.waveform")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(ECTheme.coral)
                }
                .frame(width: 74, height: 74)

                VStack(alignment: .leading, spacing: 6) {
                    Text("home.primary.title")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(ECTheme.ink)
                    if let profile = model.selectedProfile {
                        Text(profile.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(ECTheme.muted)
                    }
                }
                Spacer()
            }

            HStack(spacing: 12) {
                Button {
                    model.startImmediateCue()
                } label: {
                    Label("home.startNow", systemImage: "bolt.fill")
                }
                .buttonStyle(ECSecondaryButtonStyle())

                Button {
                    model.startSelectedCue()
                } label: {
                    Label("home.start", systemImage: "timer")
                }
                .buttonStyle(ECPrimaryButtonStyle(isDisabled: !model.canStartCue))
                .disabled(!model.canStartCue)
            }
        }
    }

    private var callerPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "home.caller")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(model.allProfiles) { profile in
                        callerCard(profile)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func callerCard(_ profile: CallerProfile) -> some View {
        let isSelected = model.selectedProfileID == profile.id
        return Button {
            model.chooseProfile(profile)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                CallerAvatar(caller: profile, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(ECTheme.ink)
                        .lineLimit(1)
                    Text(profile.relationship)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ECTheme.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: 138, height: 130, alignment: .leading)
            .padding(14)
            .background(isSelected ? ECTheme.softBlue : ECTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? ECTheme.teal : ECTheme.line, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var delayPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "home.delay")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(quickDelays, id: \.1) { title, seconds, icon in
                    delayButton(title: title, seconds: seconds, icon: icon)
                }
            }

            SurfaceBox(padding: 14) {
                HStack {
                    Label("delay.custom", systemImage: "slider.horizontal.3")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ECTheme.ink)
                    Spacer()
                    Stepper(value: $model.customDelayMinutes, in: 1...90) {
                        Text("\(model.customDelayMinutes) min")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(ECTheme.ink)
                            .monospacedDigit()
                    }
                }
                Button {
                    model.useCustomDelay()
                } label: {
                    Label("delay.useCustom", systemImage: "checkmark.circle")
                }
                .buttonStyle(ECSecondaryButtonStyle())
            }
        }
    }

    private func delayButton(title: LocalizedStringKey, seconds: Int, icon: String) -> some View {
        let isSelected = model.selectedDelaySeconds == seconds
        return Button {
            model.chooseDelay(seconds: seconds)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.subheadline.weight(.heavy))
                Spacer()
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

    private func activeCueBox(_ cue: ScheduledCue) -> some View {
        SurfaceBox {
            HStack(alignment: .center, spacing: 14) {
                CallerAvatar(caller: cue.caller, size: 56)
                VStack(alignment: .leading, spacing: 4) {
                    Text("home.active")
                        .font(.caption.weight(.black))
                        .foregroundStyle(ECTheme.teal)
                    Text(cue.caller.name)
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(ECTheme.ink)
                    Text(cue.caller.relationship)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ECTheme.muted)
                }
                Spacer()
                CountdownText(seconds: max(0, Int(ceil(cue.fireAt.timeIntervalSince(model.now)))))
            }

            HStack(spacing: 12) {
                Button {
                    model.previewActiveCue()
                } label: {
                    Label("home.preview", systemImage: "eye")
                }
                .buttonStyle(ECSecondaryButtonStyle())

                Button {
                    model.cancelActiveCue()
                } label: {
                    Label("home.cancel", systemImage: "xmark")
                }
                .buttonStyle(ECDestructiveButtonStyle())
            }
        }
    }

    private func feedbackBanner(_ key: LocalizedStringKey) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(ECTheme.green)
            Text(key)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(ECTheme.ink)
            Spacer()
        }
        .padding(12)
        .background(ECTheme.softGreen)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
