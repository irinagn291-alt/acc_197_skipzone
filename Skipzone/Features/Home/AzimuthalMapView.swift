import SwiftUI

struct AzimuthalMapView: View {
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    let home: GeoCoordinate
    let contact: GeoCoordinate?
    let qsoDate: Date
    var route: GreatCircleRoute?

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: reduceMotion || scenePhase != .active)) { timeline in
            ZStack {
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2 - 2

                    drawMapBackground(context: &context, center: center, radius: radius)
                    drawLatitudeRings(context: &context, center: center, radius: radius)
                    drawLongitudeLines(context: &context, center: center, radius: radius)
                    drawNightOverlay(context: &context, center: center, radius: radius)
                    drawGrayLine(context: &context, center: center, radius: radius)
                    if let route {
                        drawGreatCircle(context: &context, center: center, radius: radius, points: route.pathPoints)
                    }
                    if let contact {
                        drawPoint(
                            context: &context,
                            center: center,
                            radius: radius,
                            coordinate: contact,
                            color: swatch.stamp,
                            dotRadius: 4.5
                        )
                    }
                    drawPoint(
                        context: &context,
                        center: center,
                        radius: radius,
                        coordinate: home,
                        color: swatch.ink,
                        dotRadius: 4.5
                    )
                }

                if let route, route.distanceKm > 0 {
                    VStack {
                        Spacer()
                        Text("Great circle · \(SkipFormatters.bearingLabel(degrees: route.initialBearingDegrees)) · \(SkipFormatters.distanceLabel(km: route.distanceKm))")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2.7)
                            .textCase(.uppercase)
                            .foregroundStyle(swatch.muted)
                            .padding(.bottom, 13)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var parts = ["Azimuthal map centered on home position"]
        if let route {
            parts.append("Distance \(Int(route.distanceKm)) km")
            parts.append("Bearing \(Int(route.initialBearingDegrees)) degrees")
            parts.append("Great circle path shown")
        }
        if contact != nil {
            parts.append("Contact position shown")
        }
        return parts.joined(separator: ". ")
    }

    private func drawMapBackground(context: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(
                Gradient(colors: [
                    Color(hex: 0xF7F4EA),
                    Color(hex: 0xEDE7D8),
                    Color(hex: 0xE2DAC7)
                ]),
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )
        context.stroke(Path(ellipseIn: rect), with: .color(swatch.rule), lineWidth: 1)
    }

    private func drawLatitudeRings(context: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
        let fractions: [CGFloat] = [0.72, 0.58, 0.43]
        for fraction in fractions {
            let r = radius * fraction
            let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(Color(hex: 0xD3CBB6)),
                lineWidth: 1
            )
        }
    }

    private func drawLongitudeLines(context: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
        for i in 0..<6 {
            let angle = Double(i) * 30
            let rad = angle * .pi / 180
            let end = CGPoint(x: center.x + radius * sin(rad), y: center.y - radius * cos(rad))
            var path = Path()
            path.move(to: center)
            path.addLine(to: end)
            context.stroke(
                path,
                with: .color(Color(hex: 0xD3CBB6)),
                lineWidth: 1
            )
        }
    }

    private func drawNightOverlay(context: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
        let clipRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.drawLayer { layerContext in
            layerContext.clip(to: Path(ellipseIn: clipRect))
            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            layerContext.fill(
                Path(ellipseIn: rect),
                with: .linearGradient(
                    Gradient(colors: [
                        .clear,
                        .clear,
                        swatch.ink.opacity(0.12),
                        swatch.ink.opacity(0.17)
                    ]),
                    startPoint: CGPoint(x: rect.minX, y: rect.midY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.midY)
                )
            )
        }
    }

    private func drawGrayLine(context: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
        let clipRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.drawLayer { layerContext in
            layerContext.clip(to: Path(ellipseIn: clipRect))
            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            layerContext.fill(
                Path(ellipseIn: rect),
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: .clear, location: 0.455),
                        .init(color: swatch.stamp.opacity(0.33), location: 0.47),
                        .init(color: .clear, location: 0.53)
                    ]),
                    startPoint: CGPoint(x: rect.minX, y: rect.midY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.midY)
                )
            )
        }
    }

    private func drawGreatCircle(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat,
        points: [GeoCoordinate]
    ) {
        guard points.count > 1 else { return }
        var path = Path()
        for (index, point) in points.enumerated() {
            let projected = project(point, onto: center, radius: radius, centerCoord: home)
            if index == 0 { path.move(to: projected) } else { path.addLine(to: projected) }
        }
        context.stroke(
            path,
            with: .color(swatch.stamp),
            style: StrokeStyle(lineWidth: 2, lineCap: .round)
        )
    }

    private func drawPoint(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat,
        coordinate: GeoCoordinate,
        color: Color,
        dotRadius: CGFloat
    ) {
        let point = project(coordinate, onto: center, radius: radius, centerCoord: home)
        let halo = Path(ellipseIn: CGRect(
            x: point.x - dotRadius - 3,
            y: point.y - dotRadius - 3,
            width: (dotRadius + 3) * 2,
            height: (dotRadius + 3) * 2
        ))
        context.fill(halo, with: .color(color.opacity(0.15)))
        let dotRect = CGRect(
            x: point.x - dotRadius,
            y: point.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        )
        context.fill(Path(ellipseIn: dotRect), with: .color(color))
    }

    private func project(
        _ coordinate: GeoCoordinate,
        onto center: CGPoint,
        radius: CGFloat,
        centerCoord: GeoCoordinate
    ) -> CGPoint {
        let bearing = GreatCircleSolver.initialBearingDegrees(from: centerCoord, to: coordinate)
        let distance = GreatCircleSolver.haversineDistanceKm(from: centerCoord, to: coordinate)
        let maxDistance = 20015.0
        let normalized = min(distance / maxDistance, 1.0)
        let r = radius * normalized
        let rad = bearing * .pi / 180
        return CGPoint(x: center.x + r * sin(rad), y: center.y - r * cos(rad))
    }
}
