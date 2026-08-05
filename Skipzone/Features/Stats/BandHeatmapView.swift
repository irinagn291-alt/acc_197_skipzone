import SwiftUI

struct BandHeatmapView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.dismiss) private var dismiss

    private var cells: [BandHourCell] {
        BandHeatmapAggregator.aggregate(contacts: environment.contacts)
    }

    private var maxCount: Int {
        BandHeatmapAggregator.maxCount(in: cells)
    }

    private var displayBands: [RadioBand] {
        [.m160, .m80, .m40, .m20, .m15, .m10, .m6, .vhf]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkipTokens.padM) {
                header

                SkipImage.statsBanner.image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                    .accessibilityHidden(true)

                Text("Band × hour heatmap")
                    .font(SkipTokens.sectionFont())
                    .foregroundStyle(swatch.ink)

                Text("QSO count by band and UTC hour of contact.")
                    .font(SkipTokens.captionFont())
                    .foregroundStyle(swatch.olive)

                heatmapGrid
            }
            .padding(.horizontal, SkipTokens.padL)
            .padding(.bottom, SkipTokens.padL)
        }
        .padding(.top, SkipTokens.screenTop)
        .skipScreenBackground(swatch)
        .skipHiddenNavigationBar()
        .skipTheme()
    }

    private var header: some View {
        SkipToolbarHeader(kicker: "Logbook", title: "Statistics") {
            Button("Done") { dismiss() }
                .foregroundStyle(swatch.stamp)
                .skipHeaderActionStyle()
        }
        .padding(.bottom, SkipTokens.padS)
    }

    private var heatmapGrid: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Text("")
                    .frame(width: 40)
                ForEach(0..<24, id: \.self) { hour in
                    Text("\(hour)")
                        .font(.system(size: 8, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(swatch.olive)
                }
            }
            ForEach(displayBands, id: \.self) { band in
                HStack(spacing: 2) {
                    Text(band.label)
                        .font(SkipFontRegistry.callsignFont(.caption2))
                        .frame(width: 40, alignment: .leading)
                        .foregroundStyle(swatch.ink)
                    ForEach(0..<24, id: \.self) { hour in
                        let cell = cells.first { $0.band == band && $0.hour == hour }
                            ?? BandHourCell(band: band, hour: hour, count: 0)
                        let intensity = BandHeatmapAggregator.intensity(for: cell, maxCount: maxCount)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(swatch.stamp.opacity(intensity > 0 ? 0.2 + intensity * 0.8 : 0.05))
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                            .accessibilityLabel("\(band.label) hour \(hour): \(cell.count) contacts")
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
