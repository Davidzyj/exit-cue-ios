import SwiftUI

struct CueFlowView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        if let cue = model.activeCue {
            switch cue.state {
            case .scheduled, .ringing:
                RingingCueView(cue: cue)
            case .answered:
                ConversationCueView(cue: cue)
            }
        } else {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(ECTheme.green)
                Text("cue.none")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(ECTheme.ink)
                Button("common.done") {
                    model.isCuePresented = false
                }
                .buttonStyle(ECPrimaryButtonStyle())
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ECTheme.background.ignoresSafeArea())
        }
    }
}

struct RingingCueView: View {
    @EnvironmentObject private var model: AppModel
    let cue: ScheduledCue

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 28)

            IconPill(systemName: "shield.checkered", title: "cue.badge", color: ECTheme.teal)

            CallerAvatar(caller: cue.caller, size: 126)
                .padding(.top, 12)

            VStack(spacing: 8) {
                Text(cue.caller.name)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(ECTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                Text(cue.caller.relationship)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(ECTheme.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            SurfaceBox {
                Text(cue.caller.cueLine)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(ECTheme.ink)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)

            Button {
                model.toggleCueAlertMute()
            } label: {
                Label {
                    Text(LocalizedStringKey(model.isCueAlertMuted ? "cue.unmute" : "cue.mute"))
                } icon: {
                    Image(systemName: model.isCueAlertMuted ? "bell.fill" : "bell.slash.fill")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(model.isCueAlertMuted ? ECTheme.teal : ECTheme.coral)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(model.isCueAlertMuted ? ECTheme.softBlue : ECTheme.softCoral)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 18) {
                Button {
                    model.dismissCue()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 24, weight: .black))
                        Text("cue.dismiss")
                            .font(.caption.weight(.black))
                    }
                    .foregroundStyle(Color.white)
                    .frame(width: 96, height: 76)
                    .background(ECTheme.coral)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    model.answerCue()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 24, weight: .black))
                        Text("cue.answer")
                            .font(.caption.weight(.black))
                    }
                    .foregroundStyle(Color.white)
                    .frame(width: 96, height: 76)
                    .background(ECTheme.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 34)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [ECTheme.background, ECTheme.softBlue, ECTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .accessibilityIdentifier("cue-ringing-screen")
    }
}

struct ConversationCueView: View {
    @EnvironmentObject private var model: AppModel
    let cue: ScheduledCue

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                CallerAvatar(caller: cue.caller, size: 58)
                VStack(alignment: .leading, spacing: 5) {
                    Text(cue.caller.name)
                        .font(.title3.weight(.black))
                        .foregroundStyle(ECTheme.ink)
                    Text("cue.connected")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ECTheme.green)
                }
                Spacer()
            }
            .padding(.top, 32)

            VStack(alignment: .leading, spacing: 12) {
                messageBubble(text: cue.caller.cueLine, isPrimary: true)
                messageBubble(textKey: "cue.script.followup", isPrimary: false)
                messageBubble(textKey: "cue.script.close", isPrimary: false)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    model.completeCue()
                } label: {
                    Label("cue.endSafe", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(ECPrimaryButtonStyle())

                Button {
                    model.scheduleFollowUp(minutes: 5)
                } label: {
                    Label("cue.followup", systemImage: "timer")
                }
                .buttonStyle(ECSecondaryButtonStyle())
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ECTheme.background.ignoresSafeArea())
        .accessibilityIdentifier("cue-conversation-screen")
    }

    private func messageBubble(text: String, isPrimary: Bool) -> some View {
        Text(text)
            .font(.body.weight(.semibold))
            .foregroundStyle(isPrimary ? Color.white : ECTheme.ink)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isPrimary ? ECTheme.teal : ECTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func messageBubble(textKey: LocalizedStringKey, isPrimary: Bool) -> some View {
        Text(textKey)
            .font(.body.weight(.semibold))
            .foregroundStyle(isPrimary ? Color.white : ECTheme.ink)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isPrimary ? ECTheme.teal : ECTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
