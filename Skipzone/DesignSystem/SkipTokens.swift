import SwiftUI

struct SkipSwatch: Hashable, Sendable {
    let ink: Color
    let stamp: Color
    let olive: Color
    let rule: Color
    let paper: Color
    let card: Color
    let muted: Color
    let pagerBar: Color
    let pagerBarBorder: Color
    let dotInactive: Color
    let gridPillBG: Color

    static let light = SkipSwatch(
        ink: Color(hex: 0x1E3A5F),
        stamp: Color(hex: 0xA7382F),
        olive: Color(hex: 0x5E6B4A),
        rule: Color(hex: 0xC9C2AE),
        paper: Color(hex: 0xF2EEE3),
        card: Color(hex: 0xFBF8EE),
        muted: Color(hex: 0x7A7460),
        pagerBar: Color(hex: 0xEDE8D9),
        pagerBarBorder: Color(hex: 0xD8D0BC),
        dotInactive: Color(hex: 0xC6BDA6),
        gridPillBG: Color(hex: 0xF7F4EA)
    )
}

enum SkipTokens {
    static let cornerS: CGFloat = 2
    static let cornerM: CGFloat = 3
    static let cornerL: CGFloat = 2
    static let padS: CGFloat = 8
    static let padM: CGFloat = 16
    static let padL: CGFloat = 18
    static let ruleStroke: CGFloat = 1
    static let qslCardWidth: CGFloat = 304
    static let qslCardHeight: CGFloat = 168
    static let pagerDot: CGFloat = 6
    static let pagerDotActive: CGFloat = 20
    static let ruledLineSpacing: CGFloat = 25
    static let minHitTarget: CGFloat = 44
    static let screenTop: CGFloat = 8

    static func displayFont() -> Font { .system(.title2, design: .default).weight(.semibold) }
    static func sectionFont() -> Font { .system(.title3, design: .default).weight(.medium) }
    static func bodyFont() -> Font { .system(.body, design: .default) }
    static func captionFont() -> Font { .caption }
    static func actionFont() -> Font { .system(.subheadline, design: .default).weight(.bold) }
    static func callsignFont(_ style: Font.TextStyle = .body) -> Font {
        .system(style, design: .monospaced).weight(.medium)
    }
}

enum SkipChrome {
    static func logBackground(_ swatch: SkipSwatch) -> some View {
        ZStack {
            swatch.paper
            Canvas { context, size in
                var y = SkipTokens.ruledLineSpacing
                while y < size.height {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(
                        path,
                        with: .color(Color(hex: 0xEAE5D7)),
                        lineWidth: 1
                    )
                    y += SkipTokens.ruledLineSpacing
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .ignoresSafeArea()
    }

    static func panel<S: Shape>(_ swatch: SkipSwatch, shape: S = RoundedRectangle(cornerRadius: SkipTokens.cornerM)) -> some View {
        shape.fill(swatch.card)
            .overlay(shape.stroke(swatch.rule, lineWidth: SkipTokens.ruleStroke))
    }

    static func rule(_ swatch: SkipSwatch) -> some View {
        Rectangle()
            .fill(swatch.rule)
            .frame(height: SkipTokens.ruleStroke)
    }

    static func dashedRule(_ swatch: SkipSwatch) -> some View {
        Rectangle()
            .fill(swatch.rule.opacity(0.6))
            .frame(height: SkipTokens.ruleStroke)
            .overlay(
                GeometryReader { geo in
                    Path { path in
                        var x: CGFloat = 0
                        while x < geo.size.width {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: min(x + 4, geo.size.width), y: 0))
                            x += 8
                        }
                    }
                    .stroke(swatch.olive.opacity(0.4), lineWidth: SkipTokens.ruleStroke)
                }
                .frame(height: SkipTokens.ruleStroke)
            )
    }

    static func stampAccent(_ swatch: SkipSwatch) -> some View {
        RoundedRectangle(cornerRadius: SkipTokens.cornerS)
            .fill(swatch.stamp.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                    .stroke(swatch.stamp.opacity(0.5), lineWidth: SkipTokens.ruleStroke)
            )
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

private struct SkipSwatchKey: EnvironmentKey {
    static let defaultValue = SkipSwatch.light
}

extension EnvironmentValues {
    var skipSwatch: SkipSwatch {
        get { self[SkipSwatchKey.self] }
        set { self[SkipSwatchKey.self] = newValue }
    }
}

struct SkipThemeModifier: ViewModifier {
    let swatch: SkipSwatch

    func body(content: Content) -> some View {
        content
            .environment(\.skipSwatch, swatch)
            .tint(swatch.stamp)
    }
}

extension View {
    func skipTheme(_ swatch: SkipSwatch = .light) -> some View {
        modifier(SkipThemeModifier(swatch: swatch))
    }

    func skipHiddenNavigationBar() -> some View {
        toolbar(.hidden, for: .navigationBar)
    }

    func skipScreenBackground(_ swatch: SkipSwatch) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SkipChrome.logBackground(swatch).ignoresSafeArea())
    }
}
