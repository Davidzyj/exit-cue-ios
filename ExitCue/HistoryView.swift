import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    if model.history.isEmpty {
                        emptyState
                    } else {
                        SectionHeader(title: "history.recent", actionTitle: "history.clear") {
                            model.clearHistory()
                        }
                        ForEach(model.history) { item in
                            historyRow(item)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .padding(.bottom, 96)
            }
            .background(ECTheme.background.ignoresSafeArea())
            .navigationTitle("history.navTitle")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("history.title")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(ECTheme.ink)
            Text("history.subtitle")
                .font(.body.weight(.semibold))
                .foregroundStyle(ECTheme.muted)
        }
    }

    private var emptyState: some View {
        SurfaceBox {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(ECTheme.teal)
            Text("history.empty.title")
                .font(.headline.weight(.heavy))
                .foregroundStyle(ECTheme.ink)
            Text("history.empty.subtitle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ECTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func historyRow(_ item: CueHistoryItem) -> some View {
        let locale = Locale(identifier: model.effectiveLanguage.localeIdentifier)
        return SurfaceBox {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(resultColor(item.result).opacity(0.14))
                    Image(systemName: resultIcon(item.result))
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(resultColor(item.result))
                }
                .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 5) {
                    Text(item.callerName)
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(ECTheme.ink)
                    Text(item.relationship)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ECTheme.muted)
                        .lineLimit(1)
                    Text(item.date.shortDisplay(locale: locale))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ECTheme.muted)
                }
                Spacer()
                Text(resultKey(item.result))
                    .font(.caption.weight(.black))
                    .foregroundStyle(resultColor(item.result))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 7)
                    .background(resultColor(item.result).opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }

    private func resultKey(_ result: CueResult) -> LocalizedStringKey {
        switch result {
        case .completed:
            return "history.result.completed"
        case .dismissed:
            return "history.result.dismissed"
        case .cancelled:
            return "history.result.cancelled"
        }
    }

    private func resultIcon(_ result: CueResult) -> String {
        switch result {
        case .completed:
            return "checkmark"
        case .dismissed:
            return "phone.down"
        case .cancelled:
            return "xmark"
        }
    }

    private func resultColor(_ result: CueResult) -> Color {
        switch result {
        case .completed:
            return ECTheme.green
        case .dismissed:
            return ECTheme.brass
        case .cancelled:
            return ECTheme.coral
        }
    }
}
