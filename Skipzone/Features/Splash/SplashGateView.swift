import SwiftUI

struct SkipSplashGate: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false
    @State private var stampPressed = false

    var body: some View {
        Group {
            if environment.isReady {
                if environment.onboardingCompleted {
                    QSLPagerView()
                } else {
                    SkipOnboardingView()
                }
            } else {
                splashContent
            }
        }
        .skipScreenBackground(swatch)
        .skipTheme()
    }

    private var splashContent: some View {
        VStack(spacing: SkipTokens.padL) {
            ZStack {
                QSLCardStackShadow()
                VStack(alignment: .leading, spacing: SkipTokens.padS) {
                    HStack {
                        Text("K1ABC")
                            .font(SkipFontRegistry.callsignFont())
                            .foregroundStyle(swatch.ink.opacity(0.35))
                        Spacer()
                        Text("QSL")
                            .font(SkipTokens.captionFont().weight(.bold))
                            .tracking(2)
                            .foregroundStyle(swatch.stamp.opacity(0.5))
                    }
                    dashedBorder
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Skipzone")
                            .font(SkipTokens.displayFont())
                            .foregroundStyle(swatch.ink)
                        Text("Shortwave logbook")
                            .font(SkipTokens.bodyFont())
                            .foregroundStyle(swatch.olive)
                    }
                    .padding(.top, SkipTokens.padS)

                    if let error = environment.bootstrapError {
                        Text(error)
                            .font(SkipTokens.captionFont())
                            .foregroundStyle(swatch.stamp)
                            .multilineTextAlignment(.leading)
                    } else {
                        HStack {
                            Spacer()
                            Text(stampPressed ? "VERIFIED" : "LOADING")
                                .font(SkipTokens.captionFont().weight(.bold))
                                .tracking(1.6)
                                .foregroundStyle(swatch.stamp)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                                        .stroke(swatch.stamp.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                                )
                                .rotationEffect(.degrees(reduceMotion ? 0 : (stampPressed ? -3 : 3)))
                                .scaleEffect(appeared ? 1 : 0.9)
                        }
                    }
                }
                .padding(SkipTokens.padL)
                .frame(width: SkipTokens.qslCardWidth)
                .background(
                    RoundedRectangle(cornerRadius: SkipTokens.cornerL)
                        .fill(swatch.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: SkipTokens.cornerL)
                        .stroke(swatch.rule, style: StrokeStyle(lineWidth: SkipTokens.ruleStroke, dash: [6, 4]))
                )
                .shadow(color: Color(hex: 0xDFD8C6), radius: 0, x: 2, y: 3)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
        }
        .padding(.top, SkipTokens.padL)
        .padding(.horizontal, SkipTokens.padL)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            if reduceMotion {
                appeared = true
                stampPressed = true
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    appeared = true
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    stampPressed = true
                }
            }
        }
    }

    private var dashedBorder: some View {
        GeometryReader { geo in
            Path { path in
                var x: CGFloat = 0
                while x < geo.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: min(x + 4, geo.size.width), y: 0))
                    x += 8
                }
            }
            .stroke(swatch.rule, lineWidth: SkipTokens.ruleStroke)
        }
        .frame(height: SkipTokens.ruleStroke)
    }
}
