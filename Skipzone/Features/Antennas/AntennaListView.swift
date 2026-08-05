import SwiftUI

struct AntennaListView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.dismiss) private var dismiss

    @State private var showEditor = false
    @State private var editingAntenna: AerialRig?

    var body: some View {
        Group {
            if environment.antennas.isEmpty {
                VStack(spacing: 0) {
                    listHeader
                    SkipEmptyPlate(
                        image: .emptyAntennas,
                        title: "No antennas",
                        message: "Add your rigs to link them with contacts.",
                        actionTitle: "Add antenna"
                    ) {
                        editingAntenna = nil
                        showEditor = true
                    }
                }
                .padding(.horizontal, SkipTokens.padL)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: SkipTokens.padL) {
                        listHeader
                        SkipSectionBlock(title: "Rigs") {
                            ForEach(environment.antennas) { antenna in
                                SkipLogRow(
                                    title: antenna.name,
                                    subtitle: "\(antenna.kind.label) · \(antenna.bands)",
                                    trailing: "\(Int(antenna.heightMeters))m",
                                    action: {
                                        editingAntenna = antenna
                                        showEditor = true
                                    }
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        Task {
                                            try? await environment.antennasRepo.delete(id: antenna.id)
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
            AntennaEditorView(antenna: editingAntenna) {
                Task { await environment.reloadAll() }
            }
            .environmentObject(environment)
        }
        .skipTheme()
    }

    private var listHeader: some View {
        SkipToolbarHeader(kicker: "Station", title: "Antennas") {
            HStack(spacing: SkipTokens.padS) {
                Button {
                    editingAntenna = nil
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
}

struct AntennaEditorView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.dismiss) private var dismiss

    let antenna: AerialRig?
    let onSave: () -> Void

    @State private var name = ""
    @State private var kind: AntennaKind = .dipole
    @State private var bands = ""
    @State private var heightMeters = 10.0
    @State private var note = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkipTokens.padL) {
                editorHeader

                SkipSectionBlock(title: "Identity") {
                    SkipUnderlineField(title: "Name", text: $name)
                        .padding(.vertical, 12)
                    SkipSelectRow(
                        title: "Kind",
                        options: AntennaKind.allCases,
                        selection: $kind,
                        label: { $0.label }
                    )
                    SkipUnderlineField(title: "Bands", text: $bands)
                        .padding(.vertical, 12)
                }

                SkipSectionBlock(title: "Setup") {
                    antennaStepperRow(
                        label: "Height",
                        value: "\(Int(heightMeters)) m"
                    ) {
                        heightMeters = max(1, heightMeters - 1)
                    } onIncrement: {
                        heightMeters = min(50, heightMeters + 1)
                    }
                    SkipUnderlineField(title: "Note", text: $note)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, SkipTokens.padL)
            .padding(.bottom, SkipTokens.padL)
        }
        .padding(.top, SkipTokens.screenTop)
        .skipScreenBackground(swatch)
        .skipHiddenNavigationBar()
        .onAppear {
            guard let antenna else { return }
            name = antenna.name
            kind = antenna.kind
            bands = antenna.bands
            heightMeters = antenna.heightMeters
            note = antenna.note
        }
        .skipTheme()
    }

    private var editorHeader: some View {
        SkipToolbarHeader(
            kicker: "Station",
            title: antenna == nil ? "Add antenna" : "Edit antenna"
        ) {
            HStack(spacing: SkipTokens.padS) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(swatch.olive)
                    .skipHeaderActionStyle()
                Button("Save") { Task { await save() } }
                    .foregroundStyle(swatch.stamp)
                    .skipHeaderActionStyle()
                    .disabled(name.isEmpty)
            }
        }
    }

    private func antennaStepperRow(
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
                    .frame(minWidth: 48)
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
        let item = AerialRig(
            id: antenna?.id ?? UUID(),
            name: name,
            kind: kind,
            bands: bands,
            heightMeters: heightMeters,
            note: note,
            isActive: antenna?.isActive ?? true
        )
        try? await environment.antennasRepo.upsert(item)
        onSave()
        dismiss()
    }
}
