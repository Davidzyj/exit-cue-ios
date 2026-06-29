import SwiftUI

struct SectionHeader: View {
    let title: LocalizedStringKey
    var actionTitle: LocalizedStringKey?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.title3.weight(.heavy))
                .foregroundStyle(ECTheme.ink)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ECTheme.teal)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct SurfaceBox<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(padding)
        .background(ECTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(ECTheme.line.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: ECTheme.shadow, radius: 12, x: 0, y: 8)
    }
}

struct IconPill: View {
    let systemName: String
    let title: LocalizedStringKey
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .bold))
            Text(title)
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

struct CallerAvatar: View {
    let caller: CallerProfile
    var size: CGFloat = 54

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.34, weight: .black, design: .rounded))
            .foregroundStyle(Color.white)
            .frame(width: size, height: size)
            .background(Color(hex: caller.accentHex))
            .clipShape(Circle())
            .accessibilityHidden(true)
    }

    private var initials: String {
        let trimmed = caller.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else {
            return "E"
        }
        return String(first).uppercased()
    }
}

struct CountdownText: View {
    let seconds: Int

    var body: some View {
        Text(formatted)
            .font(.system(size: 28, weight: .black, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(ECTheme.ink)
    }

    private var formatted: String {
        let safeSeconds = max(0, seconds)
        let minutes = safeSeconds / 60
        let seconds = safeSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct FieldLabel: View {
    let title: LocalizedStringKey

    var body: some View {
        Text(title)
            .font(.footnote.weight(.bold))
            .foregroundStyle(ECTheme.muted)
    }
}

extension Date {
    func shortDisplay(locale: Locale) -> String {
        formatted(
            .dateTime
                .locale(locale)
                .month(.abbreviated)
                .day()
                .hour()
                .minute()
        )
    }
}

