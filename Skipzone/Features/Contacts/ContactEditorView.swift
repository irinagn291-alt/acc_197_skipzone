import SwiftUI

struct ContactEditorView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.dismiss) private var dismiss

    let contact: AirContact?
    let onSave: () -> Void

    @State private var theirCallsign = ""
    @State private var theirGrid = ""
    @State private var band: RadioBand = .m20
    @State private var mode: RadioMode = .ssb
    @State private var frequencyKHz = 14200
    @State private var rstSent = "59"
    @State private var rstReceived = "59"
    @State private var qsoAt = Date()
    @State private var note = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkipTokens.padM) {
                    header

                    SkipUnderlineField(title: "Their callsign", text: $theirCallsign)
                    SkipUnderlineField(title: "Their grid", text: $theirGrid)

                    HStack {
                        Text("Band").font(SkipTokens.captionFont()).foregroundStyle(swatch.olive)
                        Spacer()
                        Picker("Band", selection: $band) {
                            ForEach(RadioBand.allCases, id: \.self) { b in
                                Text(b.label).tag(b)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: band) { newBand in
                            frequencyKHz = Int(newBand.frequencyMHz * 1000)
                        }
                    }

                    HStack {
                        Text("Mode").font(SkipTokens.captionFont()).foregroundStyle(swatch.olive)
                        Spacer()
                        Picker("Mode", selection: $mode) {
                            ForEach(RadioMode.allCases, id: \.self) { m in
                                Text(m.label).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    SkipUnderlineField(title: "Frequency kHz", text: Binding(
                        get: { String(frequencyKHz) },
                        set: { frequencyKHz = Int($0) ?? frequencyKHz }
                    ))

                    HStack {
                        SkipUnderlineField(title: "RST sent", text: $rstSent)
                        SkipUnderlineField(title: "RST rcvd", text: $rstReceived)
                    }

                    DatePicker("QSO time", selection: $qsoAt)
                        .font(SkipTokens.bodyFont())

                    SkipUnderlineField(title: "Note", text: $note)
                }
                .padding(.horizontal, SkipTokens.padL)
                .padding(.bottom, SkipTokens.padL)
            }
            .padding(.top, SkipTokens.screenTop)
            .skipScreenBackground(swatch)
            .skipHiddenNavigationBar()
            .onAppear { loadContact() }
        }
        .skipTheme()
    }

    private var header: some View {
        SkipToolbarHeader(
            kicker: "Logbook",
            title: contact == nil ? "Log contact" : "Edit contact"
        ) {
            HStack(spacing: SkipTokens.padS) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(swatch.olive)
                    .skipHeaderActionStyle()
                Button("Save") { Task { await save() } }
                    .foregroundStyle(swatch.stamp)
                    .skipHeaderActionStyle()
                    .disabled(theirCallsign.isEmpty || isSaving)
            }
        }
    }

    private func loadContact() {
        guard let contact else { return }
        theirCallsign = contact.theirCallsign
        theirGrid = contact.theirGrid
        band = contact.band
        mode = contact.mode
        frequencyKHz = contact.frequencyKHz
        rstSent = contact.rstSent
        rstReceived = contact.rstReceived
        qsoAt = contact.qsoAt
        note = contact.note
    }

    private func save() async {
        isSaving = true
        var lat = 0.0
        var lon = 0.0
        if !theirGrid.isEmpty, let decoded = try? MaidenheadLocator.decode(theirGrid) {
            lat = decoded.latitude
            lon = decoded.longitude
        }
        let item = AirContact(
            id: contact?.id ?? UUID(),
            theirCallsign: theirCallsign.uppercased(),
            theirGrid: theirGrid.uppercased(),
            theirLatitude: lat,
            theirLongitude: lon,
            band: band,
            mode: mode,
            frequencyKHz: frequencyKHz,
            rstSent: rstSent,
            rstReceived: rstReceived,
            qsoAt: qsoAt,
            antennaID: contact?.antennaID,
            note: note,
            stationID: contact?.stationID ?? environment.stations.first(where: \.isHome)?.id
        )
        try? await environment.contactsRepo.upsert(item)
        await environment.reloadContacts()
        onSave()
        dismiss()
        isSaving = false
    }
}
