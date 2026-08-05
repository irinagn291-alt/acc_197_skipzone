import SwiftUI

struct PropNotesView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.dismiss) private var dismiss

    @State private var showEditor = false
    @State private var editingNote: PropNote?

    var body: some View {
        Group {
            if environment.propNotes.isEmpty {
                VStack(spacing: 0) {
                    listHeader
                    SkipEmptyPlate(
                        image: .emptyPropNotes,
                        title: "No propagation notes",
                        message: "Record band conditions, K-index, and solar flux observations.",
                        actionTitle: "Add note"
                    ) {
                        editingNote = nil
                        showEditor = true
                    }
                }
                .padding(.horizontal, SkipTokens.padL)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: SkipTokens.padL) {
                        listHeader
                        SkipSectionBlock(title: "Notes") {
                            ForEach(environment.propNotes) { note in
                                SkipLogRow(
                                    title: note.title,
                                    subtitle: noteSubtitle(note),
                                    trailing: SkipFormatters.qsoDate.string(from: note.recordedAt),
                                    action: {
                                        editingNote = note
                                        showEditor = true
                                    }
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        Task {
                                            try? await environment.propNotesRepo.delete(id: note.id)
                                            await environment.reloadAll()
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, SkipTokens.padL)
                    .padding(.bottom, SkipTokens.padL)
                }
            }
        }
        .padding(.top, SkipTokens.screenTop)
        .skipScreenBackground(swatch)
        .skipHiddenNavigationBar()
        .sheet(isPresented: $showEditor) {
            PropNoteEditorView(note: editingNote) {
                Task { await environment.reloadAll() }
            }
            .environmentObject(environment)
        }
        .skipTheme()
    }

    private var listHeader: some View {
        SkipToolbarHeader(kicker: "Logbook", title: "Propagation") {
            HStack(spacing: SkipTokens.padS) {
                Button {
                    editingNote = nil
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(swatch.stamp)
                        .skipHeaderActionStyle()
                }
                Button("Done") { dismiss() }
                    .foregroundStyle(swatch.stamp)
                    .skipHeaderActionStyle()
            }
        }
        .padding(.bottom, SkipTokens.padS)
    }

    private func noteSubtitle(_ note: PropNote) -> String {
        var parts: [String] = []
        if let band = note.band { parts.append(band.label) }
        if let kIndex = note.kIndex { parts.append("K \(kIndex)") }
        if let sfi = note.sfi { parts.append("SFI \(sfi)") }
        return parts.joined(separator: " · ")
    }
}

struct PropNoteEditorView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.dismiss) private var dismiss

    let note: PropNote?
    let onSave: () -> Void

    @State private var title = ""
    @State private var bodyText = ""
    @State private var band: RadioBand = .m20
    @State private var hasBand = true
    @State private var kIndex = 2
    @State private var sfi = 100
    @State private var recordedAt = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkipTokens.padL) {
                editorHeader

                SkipSectionBlock(title: "Details") {
                    SkipUnderlineField(title: "Title", text: $title)
                        .padding(.vertical, 12)
                    propNotesField
                }

                SkipSectionBlock(title: "Band") {
                    SkipToggleRow(title: "Link to band", isOn: $hasBand)
                    if hasBand {
                        SkipSelectRow(
                            title: "Band",
                            options: RadioBand.allCases,
                            selection: $band,
                            label: { $0.label }
                        )
                    }
                }

                SkipSectionBlock(title: "Conditions") {
                    propStepperRow(label: "K-index", value: "\(kIndex)") {
                        kIndex = max(0, kIndex - 1)
                    } onIncrement: {
                        kIndex = min(9, kIndex + 1)
                    }
                    propStepperRow(label: "SFI", value: "\(sfi)") {
                        sfi = max(0, sfi - 1)
                    } onIncrement: {
                        sfi = min(300, sfi + 1)
                    }
                    HStack {
                        Text("Recorded")
                            .font(SkipTokens.bodyFont().weight(.medium))
                            .foregroundStyle(swatch.ink)
                        Spacer()
                        DatePicker("", selection: $recordedAt, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .font(SkipTokens.callsignFont(.caption))
                    }
                    .padding(.vertical, 12)
                    .frame(minHeight: SkipTokens.minHitTarget)
                }
            }
            .padding(.horizontal, SkipTokens.padL)
            .padding(.bottom, SkipTokens.padL)
        }
        .padding(.top, SkipTokens.screenTop)
        .skipScreenBackground(swatch)
        .skipHiddenNavigationBar()
        .onAppear {
            guard let note else { return }
            title = note.title
            bodyText = note.body
            if let b = note.band { band = b; hasBand = true } else { hasBand = false }
            kIndex = note.kIndex ?? 2
            sfi = note.sfi ?? 100
            recordedAt = note.recordedAt
        }
        .skipTheme()
    }

    private var editorHeader: some View {
        SkipToolbarHeader(
            kicker: "Propagation",
            title: note == nil ? "Add note" : "Edit note"
        ) {
            HStack(spacing: SkipTokens.padS) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(swatch.olive)
                    .skipHeaderActionStyle()
                Button("Save") { Task { await save() } }
                    .foregroundStyle(swatch.stamp)
                    .skipHeaderActionStyle()
                    .disabled(title.isEmpty)
            }
        }
    }

    private var propNotesField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Notes".uppercased())
                .font(SkipTokens.captionFont())
                .tracking(1.2)
                .foregroundStyle(swatch.olive)
            TextField("Notes", text: $bodyText, axis: .vertical)
                .font(SkipTokens.bodyFont())
                .lineLimit(3...6)
            SkipChrome.rule(swatch)
        }
    }

    private func propStepperRow(
        label: String,
        value: String,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(label)
                .font(SkipTokens.bodyFont().weight(.medium))
                .foregroundStyle(swatch.ink)
            Spacer()
            HStack(spacing: SkipTokens.padS) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(SkipTokens.captionFont().weight(.bold))
                        .foregroundStyle(swatch.ink)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                                .stroke(swatch.rule, lineWidth: SkipTokens.ruleStroke)
                        )
                }
                .buttonStyle(.plain)
                Text(value)
                    .font(SkipTokens.callsignFont(.body))
                    .monospacedDigit()
                    .foregroundStyle(swatch.ink)
                    .frame(minWidth: 36)
                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(SkipTokens.captionFont().weight(.bold))
                        .foregroundStyle(swatch.ink)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                                .stroke(swatch.rule, lineWidth: SkipTokens.ruleStroke)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .frame(minHeight: SkipTokens.minHitTarget)
        .overlay(alignment: .bottom) {
            SkipChrome.dashedRule(swatch)
        }
    }

    private func save() async {
        let item = PropNote(
            id: note?.id ?? UUID(),
            title: title,
            body: bodyText,
            band: hasBand ? band : nil,
            recordedAt: recordedAt,
            kIndex: kIndex,
            sfi: sfi
        )
        try? await environment.propNotesRepo.upsert(item)
        onSave()
        dismiss()
    }
}
