import SwiftUI

struct SkipOnboardingView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var page = 0
    @State private var callsign = ""
    @State private var displayName = ""
    @State private var homeGrid = "FN31pr"
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let pages: [(SkipImage, String, String)] = [
        (.onboardingRadio, "Welcome to Skipzone", "An offline shortwave logbook with propagation notes and great-circle maps."),
        (.onboardingGrid, "Maidenhead grids", "Track contacts by grid square. Lat/lon is computed locally from your locator."),
        (.onboardingQsl, "QSL card pager", "Swipe through QSL cards with distance, bearing, and gray-line overlay."),
        (.onboardingLog, "Your station", "Set your callsign and home grid to anchor the azimuthal map.")
    ]

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SkipTokens.padM) {
                    ZStack {
                        ForEach(0..<pages.count, id: \.self) { index in
                            if index <= page {
                                onboardingCard(index: index)
                                    .offset(
                                        x: CGFloat(index - page) * 12,
                                        y: CGFloat(index - page) * 8
                                    )
                                    .scaleEffect(index == page ? 1 : 0.96 - CGFloat(page - index) * 0.02)
                                    .opacity(index < page ? 0.4 : 1)
                                    .zIndex(Double(index))
                            }
                        }
                    }
                    .frame(minHeight: 280)

                    PageDots(count: pages.count, selected: page)

                    if page == pages.count - 1 {
                        setupForm
                    }

                    HStack(spacing: SkipTokens.padM) {
                        if page > 0 {
                            Button("BACK") { setPage(page - 1) }
                                .buttonStyle(SkipSecondaryButtonStyle())
                        }
                        if page < pages.count - 1 {
                            Button("NEXT QSO") { setPage(page + 1) }
                                .buttonStyle(SkipPrimaryButtonStyle())
                                .frame(maxWidth: .infinity)
                        } else {
                            Button(isSaving ? "SENDING…" : "CONFIRM") {
                                Task { await finish() }
                            }
                            .buttonStyle(SkipPrimaryButtonStyle())
                            .frame(maxWidth: .infinity)
                            .disabled(callsign.isEmpty || isSaving)
                        }
                    }
                }
                .padding(.horizontal, SkipTokens.padL)
                .padding(.vertical, SkipTokens.padL)
                .frame(minHeight: proxy.size.height, alignment: .center)
            }
        }
        .padding(.top, SkipTokens.screenTop)
        .skipTheme()
    }

    private func onboardingCard(index: Int) -> some View {
        let item = pages[index]
        return VStack(alignment: .leading, spacing: SkipTokens.padS) {
            item.0.image
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 140)
                .frame(maxWidth: .infinity)
            Text(item.1)
                .font(SkipTokens.displayFont())
                .foregroundStyle(swatch.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(item.2)
                .font(SkipTokens.bodyFont())
                .foregroundStyle(swatch.olive)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SkipTokens.padL)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: SkipTokens.cornerL)
                .fill(swatch.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: SkipTokens.cornerL)
                .stroke(swatch.rule, lineWidth: SkipTokens.ruleStroke)
        )
        .shadow(color: Color(hex: 0xDFD8C6), radius: 0, x: 2, y: 3)
    }

    private var setupForm: some View {
        VStack(spacing: SkipTokens.padS) {
            SkipUnderlineField(title: "Callsign", text: $callsign)
            SkipUnderlineField(title: "Name", text: $displayName)
            SkipUnderlineField(title: "Home grid", text: $homeGrid)
            if let errorMessage {
                Text(errorMessage)
                    .font(SkipTokens.captionFont())
                    .foregroundStyle(swatch.stamp)
            }
        }
        .textInputAutocapitalization(.characters)
    }

    private func finish() async {
        isSaving = true
        errorMessage = nil
        do {
            _ = try MaidenheadLocator.decode(homeGrid)
            try await environment.completeOnboarding(
                callsign: callsign,
                displayName: displayName.isEmpty ? callsign : displayName,
                homeGrid: homeGrid
            )
        } catch {
            errorMessage = "Check your grid square format."
        }
        isSaving = false
    }

    private func setPage(_ value: Int) {
        if reduceMotion {
            page = value
        } else {
            withAnimation { page = value }
        }
    }
}
