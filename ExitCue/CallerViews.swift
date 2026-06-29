import SwiftUI

struct CallersView: View {
    @EnvironmentObject private var model: AppModel
    @State private var editorRoute: CallerEditorRoute?
    @State private var pendingDelete: CallerProfile?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    builtInSection
                    customSection
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .padding(.bottom, 96)
            }
            .background(ECTheme.background.ignoresSafeArea())
            .navigationTitle("callers.navTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editorRoute = CallerEditorRoute(profile: nil)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .black))
                    }
                    .accessibilityLabel(Text("callers.add"))
                }
            }
            .sheet(item: $editorRoute) { route in
                CallerEditorView(profile: route.profile)
                    .environmentObject(model)
                    .presentationDetents([.large])
                    .preferredColorScheme(.light)
            }
            .confirmationDialog(
                "callers.delete.title",
                isPresented: Binding(
                    get: { pendingDelete != nil },
                    set: { isPresented in
                        if !isPresented {
                            pendingDelete = nil
                        }
                    }
                ),
                presenting: pendingDelete
            ) { profile in
                Button("callers.delete.confirm", role: .destructive) {
                    model.deleteProfile(profile)
                }
                Button("common.cancel", role: .cancel) {}
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("callers.title")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(ECTheme.ink)
            Text("callers.subtitle")
                .font(.body.weight(.semibold))
                .foregroundStyle(ECTheme.muted)
        }
    }

    private var builtInSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "callers.builtin")
            ForEach(model.allProfiles.filter(\.isBuiltIn)) { profile in
                CallerRow(profile: profile, isSelected: model.selectedProfileID == profile.id) {
                    model.chooseProfile(profile)
                } editAction: {
                } deleteAction: {
                }
            }
        }
    }

    private var customSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "callers.custom", actionTitle: "callers.add") {
                editorRoute = CallerEditorRoute(profile: nil)
            }
            if model.customProfiles.isEmpty {
                SurfaceBox {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(ECTheme.teal)
                        Text("callers.empty")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(ECTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                ForEach(model.customProfiles) { profile in
                    CallerRow(profile: profile, isSelected: model.selectedProfileID == profile.id) {
                        model.chooseProfile(profile)
                    } editAction: {
                        editorRoute = CallerEditorRoute(profile: profile)
                    } deleteAction: {
                        pendingDelete = profile
                    }
                }
            }
        }
    }
}

struct CallerEditorRoute: Identifiable {
    let id = UUID()
    var profile: CallerProfile?
}

struct CallerRow: View {
    let profile: CallerProfile
    let isSelected: Bool
    let selectAction: () -> Void
    let editAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        SurfaceBox {
            HStack(alignment: .center, spacing: 14) {
                CallerAvatar(caller: profile, size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(profile.name)
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(ECTheme.ink)
                            .lineLimit(1)
                        if profile.isBuiltIn {
                            Text("callers.builtin.badge")
                                .font(.caption2.weight(.black))
                                .foregroundStyle(ECTheme.brass)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(ECTheme.brass.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    Text(profile.relationship)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ECTheme.muted)
                    Text(profile.cueLine)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(ECTheme.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(ECTheme.teal)
                }
            }

            HStack(spacing: 10) {
                Button(action: selectAction) {
                    Label(isSelected ? "callers.selected" : "callers.use", systemImage: isSelected ? "checkmark" : "person.fill.checkmark")
                }
                .buttonStyle(ECSecondaryButtonStyle())

                if !profile.isBuiltIn {
                    Button(action: editAction) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(ECTheme.ink)
                            .frame(width: 48, height: 48)
                            .background(ECTheme.elevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(ECTheme.line, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .accessibilityLabel(Text("common.edit"))

                    Button(action: deleteAction) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(ECTheme.coral)
                            .frame(width: 48, height: 48)
                            .background(ECTheme.elevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(ECTheme.line, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .accessibilityLabel(Text("common.delete"))
                }
            }
        }
    }
}

struct CallerEditorView: View {
    enum Field {
        case name
        case relationship
        case cueLine
    }

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    private let profile: CallerProfile?

    @State private var name: String
    @State private var relationship: String
    @State private var cueLine: String
    @State private var accentHex: String

    private let accents = ["#E05F5F", "#326D80", "#7A6A2E", "#397A55", "#B76E79", "#6356A5"]

    init(profile: CallerProfile?) {
        self.profile = profile
        _name = State(initialValue: profile?.name ?? "")
        _relationship = State(initialValue: profile?.relationship ?? "")
        _cueLine = State(initialValue: profile?.cueLine ?? "")
        _accentHex = State(initialValue: profile?.accentHex ?? "#326D80")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    editorHeader
                    inputGroup
                    accentPicker
                    Button {
                        save()
                    } label: {
                        Label("common.save", systemImage: "checkmark")
                    }
                    .buttonStyle(ECPrimaryButtonStyle(isDisabled: !canSave))
                    .disabled(!canSave)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
            .background(ECTheme.background.ignoresSafeArea())
            .navigationTitle(profile == nil ? "callers.editor.addTitle" : "callers.editor.editTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.cancel") {
                        focusedField = nil
                        dismiss()
                    }
                    .foregroundStyle(ECTheme.teal)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("common.done") {
                        focusedField = nil
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var editorHeader: some View {
        SurfaceBox {
            HStack(spacing: 14) {
                CallerAvatar(
                    caller: CallerProfile(name: name.isEmpty ? "E" : name, relationship: relationship, cueLine: cueLine, accentHex: accentHex),
                    size: 64
                )
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile == nil ? "callers.editor.newProfile" : "callers.editor.updateProfile")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(ECTheme.ink)
                    Text("callers.editor.caption")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ECTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var inputGroup: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "callers.editor.name")
                TextField("", text: $name, prompt: Text("callers.editor.name.placeholder").foregroundStyle(ECTheme.placeholder))
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .name)
                    .onSubmit { focusedField = .relationship }
                    .textFieldStyle(ECTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "callers.editor.relationship")
                TextField("", text: $relationship, prompt: Text("callers.editor.relationship.placeholder").foregroundStyle(ECTheme.placeholder))
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .relationship)
                    .onSubmit { focusedField = .cueLine }
                    .textFieldStyle(ECTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 6) {
                FieldLabel(title: "callers.editor.cueLine")
                TextField("", text: $cueLine, prompt: Text("callers.editor.cueLine.placeholder").foregroundStyle(ECTheme.placeholder), axis: .vertical)
                    .lineLimit(3...5)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .cueLine)
                    .onSubmit { focusedField = nil }
                    .textFieldStyle(ECTextFieldStyle())
            }
        }
    }

    private var accentPicker: some View {
        SurfaceBox {
            FieldLabel(title: "callers.editor.color")
            HStack(spacing: 12) {
                ForEach(accents, id: \.self) { hex in
                    Button {
                        accentHex = hex
                    } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(accentHex == hex ? ECTheme.ink : Color.clear, lineWidth: 3)
                            )
                            .overlay {
                                if accentHex == hex {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .black))
                                        .foregroundStyle(Color.white)
                                }
                            }
                    }
                    .accessibilityLabel(Text("callers.editor.color"))
                }
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !relationship.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !cueLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        focusedField = nil
        if let profile {
            var updated = profile
            updated.name = name
            updated.relationship = relationship
            updated.cueLine = cueLine
            updated.accentHex = accentHex
            model.updateProfile(updated)
        } else {
            model.addProfile(name: name, relationship: relationship, cueLine: cueLine, accentHex: accentHex)
        }
        dismiss()
    }
}

struct ECTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.body.weight(.semibold))
            .foregroundStyle(ECTheme.ink)
            .tint(ECTheme.teal)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(ECTheme.elevated)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(ECTheme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
