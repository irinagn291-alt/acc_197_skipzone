import Foundation

enum GreatCircleSolver {
    private static let earthRadiusKm = 6371.0

    static func haversineDistanceKm(
        from origin: GeoCoordinate,
        to destination: GeoCoordinate
    ) -> Double {
        let lat1 = origin.latitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let dLat = (destination.latitude - origin.latitude) * .pi / 180
        let dLon = (destination.longitude - origin.longitude) * .pi / 180

        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c
    }

    static func initialBearingDegrees(
        from origin: GeoCoordinate,
        to destination: GeoCoordinate
    ) -> Double {
        let lat1 = origin.latitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let dLon = (destination.longitude - origin.longitude) * .pi / 180

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi
        return normalizeDegrees(bearing)
    }

    static func longPath(
        from origin: GeoCoordinate,
        to destination: GeoCoordinate
    ) -> (distanceKm: Double, bearingDegrees: Double) {
        let shortDistance = haversineDistanceKm(from: origin, to: destination)
        let shortBearing = initialBearingDegrees(from: origin, to: destination)
        let longBearing = normalizeDegrees(shortBearing + 180)
        let circumference = 2 * .pi * earthRadiusKm
        return (circumference - shortDistance, longBearing)
    }

    static func route(
        from origin: GeoCoordinate,
        to destination: GeoCoordinate,
        segments: Int = 64
    ) -> GreatCircleRoute {
        let distance = haversineDistanceKm(from: origin, to: destination)
        let bearing = initialBearingDegrees(from: origin, to: destination)
        let long = longPath(from: origin, to: destination)
        let points = interpolateGreatCircle(from: origin, to: destination, segments: segments)
        return GreatCircleRoute(
            distanceKm: distance,
            initialBearingDegrees: bearing,
            longPathDistanceKm: long.distanceKm,
            longPathBearingDegrees: long.bearingDegrees,
            pathPoints: points
        )
    }

    static func interpolateGreatCircle(
        from origin: GeoCoordinate,
        to destination: GeoCoordinate,
        segments: Int
    ) -> [GeoCoordinate] {
        guard segments > 1 else { return [origin, destination] }

        let lat1 = origin.latitude * .pi / 180
        let lon1 = origin.longitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let lon2 = destination.longitude * .pi / 180

        let d = 2 * asin(sqrt(
            pow(sin((lat2 - lat1) / 2), 2)
                + cos(lat1) * cos(lat2) * pow(sin((lon2 - lon1) / 2), 2)
        ))

        var points: [GeoCoordinate] = []
        for step in 0...segments {
            let f = Double(step) / Double(segments)
            if d == 0 {
                points.append(origin)
                continue
            }
            let a = sin((1 - f) * d) / sin(d)
            let b = sin(f * d) / sin(d)
            let x = a * cos(lat1) * cos(lon1) + b * cos(lat2) * cos(lon2)
            let y = a * cos(lat1) * sin(lon1) + b * cos(lat2) * sin(lon2)
            let z = a * sin(lat1) + b * sin(lat2)
            let lat = atan2(z, sqrt(x * x + y * y)) * 180 / .pi
            let lon = atan2(y, x) * 180 / .pi
            points.append(GeoCoordinate(latitude: lat, longitude: lon))
        }
        return points
    }

    static func solarDeclination(for date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let angle = 2 * .pi * (Double(dayOfYear) - 1) / 365.25
        return 23.44 * sin(angle - 1.39)
    }

    static func hourAngleDegrees(for date: Date, longitude: Double) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let utcHours = Double(components.hour ?? 0)
            + Double(components.minute ?? 0) / 60
            + Double(components.second ?? 0) / 3600
        let solarTime = utcHours + longitude / 15
        return (solarTime - 12) * 15
    }

    static func solarGeometry(for date: Date, observerLongitude: Double = 0) -> SolarGeometry {
        let declination = solarDeclination(for: date)
        let hourAngle = hourAngleDegrees(for: date, longitude: observerLongitude)
        let terminator = terminatorPoints(declinationDegrees: declination, segments: 72)
        return SolarGeometry(
            declinationDegrees: declination,
            hourAngleDegrees: hourAngle,
            terminatorPoints: terminator
        )
    }

    static func terminatorPoints(
        declinationDegrees: Double,
        segments: Int = 72
    ) -> [GeoCoordinate] {
        let dec = declinationDegrees * .pi / 180
        var points: [GeoCoordinate] = []
        for step in 0...segments {
            let lon = -180 + (360 * Double(step) / Double(segments))
            let lonRad = lon * .pi / 180
            let tanDec = tan(dec)
            let cosLon = cos(lonRad)
            if abs(cosLon) < 1e-9 {
                points.append(GeoCoordinate(latitude: 0, longitude: lon))
                continue
            }
            let latRad = atan(-cosLon / tanDec)
            let lat = latRad * 180 / .pi
            points.append(GeoCoordinate(latitude: lat, longitude: lon))
        }
        return points
    }

    private static func normalizeDegrees(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }
}
