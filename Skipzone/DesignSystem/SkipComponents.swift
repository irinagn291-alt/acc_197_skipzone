import SwiftUI

struct SkipEmptyPlate: View {
    @Environment(\.skipSwatch) private var swatch
    let image: SkipImage
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: SkipTokens.padM) {
            image.image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240, maxHeight: 180)
                .accessibilityHidden(true)

            Text(title)
                .font(SkipTokens.sectionFont())
                .foregroundStyle(swatch.ink)

            Text(message)
                .font(SkipTokens.bodyFont())
                .foregroundStyle(swatch.olive)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(SkipPrimaryButtonStyle())
                    .padding(.top, SkipTokens.padS)
            }
        }
        .padding(SkipTokens.padL)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SkipPrimaryButtonStyle: ButtonStyle {
    @Environment(\.skipSwatch) private var swatch

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SkipTokens.captionFont().weight(.bold))
            .tracking(1.4)
            .textCase(.uppercase)
            .foregroundStyle(swatch.card)
            .padding(.horizontal, SkipTokens.padM)
            .padding(.vertical, SkipTokens.padS)
            .frame(minHeight: SkipTokens.minHitTarget)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(swatch.ink.opacity(configuration.isPressed ? 0.85 : 1))
            )
    }
}

struct SkipSecondaryButtonStyle: ButtonStyle {
    @Environment(\.skipSwatch) private var swatch

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SkipTokens.bodyFont())
            .foregroundStyle(swatch.ink)
            .padding(.horizontal, SkipTokens.padM)
            .padding(.vertical, SkipTokens.padS)
            .frame(minHeight: SkipTokens.minHitTarget)
            .background(
                RoundedRectangle(cornerRadius: SkipTokens.cornerM)
                    .stroke(swatch.rule, lineWidth: SkipTokens.ruleStroke)
                    .background(RoundedRectangle(cornerRadius: SkipTokens.cornerM).fill(swatch.card))
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SkipUnderlineField: View {
    @Environment(\.skipSwatch) private var swatch
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(SkipTokens.captionFont())
                .tracking(1.2)
                .foregroundStyle(swatch.olive)
            TextField(title, text: $text)
                .font(SkipFontRegistry.callsignFont())
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
            SkipChrome.rule(swatch)
        }
    }
}

struct QSLCardView: View {
    @Environment(\.skipSwatch) private var swatch
    let contact: AirContact
    let route: GreatCircleRoute?

    private var utcString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: contact.qsoAt)
    }

    private var theirGrid: String {
        MaidenheadLocator.encode(
            latitude: contact.theirLatitude,
            longitude: contact.theirLongitude,
            precision: .subsquare
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(contact.theirCallsign)
                    .font(.system(size: 21, design: .monospaced).weight(.medium))
                    .tracking(1.9)
                    .foregroundStyle(swatch.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: SkipTokens.padS)
                Text("CONFIRM")
                    .font(.system(size: 8.5, weight: .medium))
                    .tracking(2.1)
                    .textCase(.uppercase)
                    .foregroundStyle(swatch.stamp)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                            .fill(Color(hex: 0xFDF3F1))
                            .overlay(
                                RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                                    .stroke(Color(hex: 0xD8B7B2), lineWidth: SkipTokens.ruleStroke)
                            )
                    )
                    .rotationEffect(.degrees(-4))
            }

            HStack(alignment: .top, spacing: 16) {
                qslCell(label: "Band", value: contact.band.label)
                qslCell(label: "Mode", value: contact.mode.label)
                qslCell(label: "RST", value: "\(contact.rstSent)/\(contact.rstReceived)")
                qslCell(label: "UTC", value: utcString)
            }
            .padding(.top, 11)

            if let route {
                dashedDivider
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                VStack(alignment: .leading, spacing: 4) {
                    Text(SkipFormatters.distanceLabel(km: route.distanceKm))
                        .font(.system(size: 22, weight: .regular, design: .default))
                        .monospacedDigit()
                        .foregroundStyle(swatch.ink)
                    Text("\(theirGrid) · long path \(SkipFormatters.distanceLabel(km: route.distanceKm * 2.17))")
                        .font(.system(size: 10))
                        .foregroundStyle(swatch.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .frame(width: SkipTokens.qslCardWidth, height: SkipTokens.qslCardHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: SkipTokens.cornerL)
                .fill(swatch.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: SkipTokens.cornerL)
                .stroke(swatch.rule, lineWidth: SkipTokens.ruleStroke)
        )
        .shadow(color: Color(hex: 0xDFD8C6), radius: 0, x: 2, y: 3)
        .shadow(color: Color(hex: 0xE8E2D1), radius: 0, x: 4, y: 6)
    }

    private var dashedDivider: some View {
        GeometryReader { geo in
            Path { path in
                var x: CGFloat = 0
                while x < geo.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: min(x + 4, geo.size.width), y: 0))
                    x += 8
                }
            }
            .stroke(Color(hex: 0xD3CBB6), lineWidth: SkipTokens.ruleStroke)
        }
        .frame(height: SkipTokens.ruleStroke)
        .padding(.top, 10)
    }

    private func qslCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .medium))
                .tracking(1.4)
                .foregroundStyle(Color(hex: 0x8B8574))
            Text(value)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(swatch.ink)
        }
    }
}

struct QSLCardStackShadow: View {
    @Environment(\.skipSwatch) private var swatch

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SkipTokens.cornerL)
                .fill(Color(hex: 0xDFD8C6))
                .frame(width: SkipTokens.qslCardWidth, height: SkipTokens.qslCardHeight)
                .offset(x: 4, y: 6)
            RoundedRectangle(cornerRadius: SkipTokens.cornerL)
                .fill(Color(hex: 0xE8E2D1))
                .frame(width: SkipTokens.qslCardWidth, height: SkipTokens.qslCardHeight)
                .offset(x: 2, y: 3)
        }
    }
}

struct PageDots: View {
    @Environment(\.skipSwatch) private var swatch
    let count: Int
    let selected: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<count, id: \.self) { index in
                RoundedRectangle(cornerRadius: index == selected ? 3 : SkipTokens.pagerDot / 2)
                    .fill(index == selected ? swatch.ink : swatch.dotInactive)
                    .frame(
                        width: index == selected ? SkipTokens.pagerDotActive : SkipTokens.pagerDot,
                        height: SkipTokens.pagerDot
                    )
                    .animation(.easeOut(duration: 0.2), value: selected)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(selected + 1) of \(count)")
    }
}

struct SkipSectionBlock<Content: View>: View {
    @Environment(\.skipSwatch) private var swatch
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: SkipTokens.padS) {
            Text(title.uppercased())
                .font(SkipTokens.captionFont().weight(.bold))
                .tracking(1.6)
                .foregroundStyle(swatch.olive)
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, SkipTokens.padM)
            .background(SkipChrome.panel(swatch))
        }
    }
}

struct SkipLogRow: View {
    @Environment(\.skipSwatch) private var swatch
    let title: String
    var subtitle: String? = nil
    var trailing: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            ViewThatFits {
                HStack(alignment: .firstTextBaseline, spacing: SkipTokens.padS) {
                    leadingContent
                    Spacer(minLength: 8)
                    if let trailing { trailingContent(trailing) }
                }
                VStack(alignment: .leading, spacing: 3) {
                    leadingContent
                    if let trailing { trailingContent(trailing) }
                }
            }
            .padding(.vertical, 12)
            .frame(minHeight: SkipTokens.minHitTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .overlay(alignment: .bottom) {
            SkipChrome.dashedRule(swatch)
        }
    }

    private var leadingContent: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(SkipTokens.bodyFont().weight(.medium))
                .foregroundStyle(swatch.ink)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(SkipTokens.captionFont())
                    .foregroundStyle(swatch.olive)
            }
        }
    }

    private func trailingContent(_ value: String) -> some View {
        Text(value)
            .font(SkipTokens.callsignFont(.caption))
            .foregroundStyle(swatch.ink)
            .monospacedDigit()
    }
}

struct SkipToggleRow: View {
    @Environment(\.skipSwatch) private var swatch
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(SkipTokens.bodyFont().weight(.medium))
                    .foregroundStyle(swatch.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(SkipTokens.captionFont())
                        .foregroundStyle(swatch.olive)
                }
            }
            Spacer()
            SkipStationSwitch(isOn: $isOn)
        }
        .padding(.vertical, 12)
        .frame(minHeight: SkipTokens.minHitTarget)
        .overlay(alignment: .bottom) {
            SkipChrome.dashedRule(swatch)
        }
    }
}

struct SkipStationSwitch: View {
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var isOn: Bool

    var body: some View {
        Button {
            if reduceMotion {
                isOn.toggle()
            } else {
                withAnimation(.easeOut(duration: 0.15)) { isOn.toggle() }
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                    .fill(isOn ? swatch.stamp.opacity(0.35) : swatch.paper)
                    .overlay(
                        RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                            .stroke(isOn ? swatch.stamp : swatch.rule, lineWidth: SkipTokens.ruleStroke)
                    )
                RoundedRectangle(cornerRadius: 1)
                    .fill(isOn ? swatch.stamp : swatch.olive)
                    .frame(width: 14, height: 18)
                    .padding(3)
            }
            .frame(width: 44, height: 26)
        }
        .buttonStyle(.plain)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

struct SkipSelectRow<T: Hashable>: View {
    @Environment(\.skipSwatch) private var swatch
    let title: String
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(SkipTokens.captionFont().weight(.bold))
                .tracking(1.4)
                .foregroundStyle(swatch.olive)
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    HStack {
                        Text(label(option))
                            .font(SkipTokens.bodyFont())
                            .foregroundStyle(swatch.ink)
                        Spacer()
                        if selection == option {
                            Circle()
                                .strokeBorder(swatch.stamp, lineWidth: 2)
                                .background(Circle().fill(swatch.stamp.opacity(0.3)))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .overlay(alignment: .bottom) {
                    SkipChrome.dashedRule(swatch)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct SkipToolbarHeader<Trailing: View>: View {
    @Environment(\.skipSwatch) private var swatch
    let kicker: String
    let title: String
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .center, spacing: SkipTokens.padS) {
            VStack(alignment: .leading, spacing: 3) {
                Text(kicker.uppercased())
                    .font(SkipTokens.captionFont().weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(swatch.olive)
                Text(title)
                    .font(SkipTokens.displayFont())
                    .foregroundStyle(swatch.ink)
            }
            Spacer(minLength: 8)
            trailing()
        }
    }
}

struct SkipScreenHeader: View {
    @Environment(\.skipSwatch) private var swatch
    let kicker: String
    let title: String
    var trailingTitle: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text(kicker.uppercased())
                    .font(SkipTokens.captionFont().weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(swatch.olive)
                Text(title)
                    .font(SkipTokens.displayFont())
                    .foregroundStyle(swatch.ink)
            }
            Spacer()
            if let trailingTitle, let trailingAction {
                Button(action: trailingAction) {
                    Text(trailingTitle.uppercased())
                        .font(SkipTokens.captionFont().weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(swatch.paper)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(swatch.stamp)
                        .clipShape(RoundedRectangle(cornerRadius: SkipTokens.cornerS))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

extension View {
    func skipHeaderActionStyle() -> some View {
        self
            .font(SkipTokens.actionFont())
            .frame(minWidth: SkipTokens.minHitTarget, minHeight: SkipTokens.minHitTarget)
            .contentShape(Rectangle())
    }
}
