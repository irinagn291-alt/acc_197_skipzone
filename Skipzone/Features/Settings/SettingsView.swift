import SwiftUI

struct SkipSettingsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkipTokens.padL) {
                SkipToolbarHeader(kicker: "Station", title: "QTH card") {
                    Button("Done") { dismiss() }
                        .foregroundStyle(swatch.stamp)
                        .skipHeaderActionStyle()
                }

                SkipSectionBlock(title: "QTH desk") {
                    NavigationLink {
                        StationProfileView()
                            .environmentObject(environment)
                    } label: {
                        SkipLogRow(title: "Station profile", subtitle: "Callsign, grid, power", trailing: "QTH")
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SkipBackupView()
                            .environmentObject(environment)
                    } label: {
                        SkipLogRow(title: "Backup", subtitle: "Export logbook tray", trailing: "ADIF")
                    }
                    .buttonStyle(.plain)
                }

                SkipSectionBlock(title: "Traffic") {
                    SkipLogRow(
                        title: "Contacts",
                        subtitle: "Logged QSOs",
                        trailing: "\(environment.contacts.count)"
                    )
                    SkipLogRow(
                        title: "Antennas",
                        subtitle: "Station antennas",
                        trailing: "\(environment.antennas.count)"
                    )
                    SkipLogRow(
                        title: "Prop notes",
                        subtitle: "Propagation scraps",
                        trailing: "\(environment.propNotes.count)"
                    )
                }

                SkipSectionBlock(title: "Station mark") {
                    HStack(spacing: SkipTokens.padM) {
                        SkipImage.brandMark.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Skipzone")
                                .font(SkipTokens.sectionFont())
                                .foregroundStyle(swatch.ink)
                            Text("Offline shortwave logbook")
                                .font(SkipTokens.captionFont())
                                .foregroundStyle(swatch.olive)
                            Text("Version 1.0")
                                .font(SkipTokens.callsignFont(.caption))
                                .foregroundStyle(swatch.olive)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, SkipTokens.padL)
            .padding(.bottom, SkipTokens.padL)
        }
        .padding(.top, SkipTokens.screenTop)
        .skipScreenBackground(swatch)
        .skipHiddenNavigationBar()
        .skipTheme()
    }
}
