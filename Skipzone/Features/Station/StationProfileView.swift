import SwiftUI

struct StationProfileView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.dismiss) private var dismiss

    @State private var callsign = ""
    @State private var displayName = ""
    @State private var homeGrid = ""
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkipTokens.padM) {
                header

                SkipUnderlineField(title: "Callsign", text: $callsign)
                SkipUnderlineField(title: "Display name", text: $displayName)
                SkipUnderlineField(title: "Home grid", text: $homeGrid)

                if let profile = environment.operatorProfile {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Coordinates")
                            .font(SkipTokens.captionFont())
                            .foregroundStyle(swatch.olive)
                        Text(String(format: "%.4f°, %.4f°", profile.homeLatitude, profile.homeLongitude))
                            .font(SkipFontRegistry.callsignFont(.caption))
                            .foregroundStyle(swatch.ink)
                    }
                    .padding(.top, SkipTokens.padS)
                }

                Button("Save profile") {
                    Task { await save() }
                }
                .buttonStyle(SkipPrimaryButtonStyle())
                .disabled(callsign.isEmpty || isSaving)
            }
            .padding(.horizontal, SkipTokens.padL)
            .padding(.bottom, SkipTokens.padL)
        }
        .padding(.top, SkipTokens.screenTop)
        .skipScreenBackground(swatch)
        .skipHiddenNavigationBar()
        .onAppear { loadProfile() }
        .skipTheme()
    }

    private var header: some View {
        SkipToolbarHeader(kicker: "Station", title: "Operator profile") {
            Button("Done") { dismiss() }
                .foregroundStyle(swatch.stamp)
                .skipHeaderActionStyle()
        }
        .padding(.bottom, SkipTokens.padS)
    }

    private func loadProfile() {
        guard let profile = environment.operatorProfile else { return }
        callsign = profile.callsign
        displayName = profile.displayName
        homeGrid = profile.homeGrid
    }

    private func save() async {
        isSaving = true
        guard let coords = try? MaidenheadLocator.decode(homeGrid) else {
            isSaving = false
            return
        }
        let profile = OperatorProfile(
            id: environment.operatorProfile?.id ?? UUID(),
            callsign: callsign.uppercased(),
            displayName: displayName,
            homeGrid: homeGrid.uppercased(),
            homeLatitude: coords.latitude,
            homeLongitude: coords.longitude
        )
        try? await environment.profileRepo.upsert(profile)
        await environment.reloadAll()
        isSaving = false
    }
}
