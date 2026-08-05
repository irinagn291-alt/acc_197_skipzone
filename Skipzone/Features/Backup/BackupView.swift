import SwiftUI
import UniformTypeIdentifiers

struct SkipBackupView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch

    @State private var exportData: Data?
    @State private var showImporter = false
    @State private var statusMessage: String?
    @State private var isWorking = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkipTokens.padL) {
                SkipScreenHeader(kicker: "Station QTH", title: "Log archive")

                SkipImage.backupEmpty.image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                    .accessibilityHidden(true)
                    .frame(maxWidth: .infinity)

                SkipSectionBlock(title: "Desk transfer") {
                    VStack(alignment: .leading, spacing: SkipTokens.padM) {
                        Text("Export your logbook as JSON and import it on another device. All data stays offline.")
                            .font(SkipTokens.bodyFont())
                            .foregroundStyle(swatch.olive)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        if let exportData {
                            ShareLink(
                                item: BackupDocument(data: exportData),
                                preview: SharePreview("Skipzone backup", image: Image(systemName: "doc.text"))
                            ) {
                                Label("Share backup", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SkipPrimaryButtonStyle())
                        } else {
                            Button(isWorking ? "Preparing…" : "Prepare export") {
                                Task { await prepareExport() }
                            }
                            .buttonStyle(SkipPrimaryButtonStyle())
                            .disabled(isWorking)
                        }

                        Button("Import backup") {
                            showImporter = true
                        }
                        .buttonStyle(SkipSecondaryButtonStyle())

                        if let statusMessage {
                            Text(statusMessage)
                                .font(SkipTokens.captionFont())
                                .foregroundStyle(swatch.stamp)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, SkipTokens.padS)
                }
            }
            .padding(.horizontal, SkipTokens.padL)
            .padding(.bottom, SkipTokens.padL)
        }
        .padding(.top, SkipTokens.screenTop)
        .skipScreenBackground(swatch)
        .skipHiddenNavigationBar()
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            Task { await importBackup(result) }
        }
        .skipTheme()
    }

    private func prepareExport() async {
        isWorking = true
        do {
            exportData = try await environment.backup.exportJSON()
            statusMessage = "Backup ready to share."
        } catch {
            statusMessage = error.localizedDescription
        }
        isWorking = false
    }

    private func importBackup(_ result: Result<[URL], Error>) async {
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            try await environment.backup.restore(from: data)
            await environment.reloadAll()
            statusMessage = "Backup restored successfully."
            exportData = nil
        } catch {
            statusMessage = "Import failed: \(error.localizedDescription)"
        }
    }
}

struct BackupDocument: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { document in
            document.data
        }
    }
}
