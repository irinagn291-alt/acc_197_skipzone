import Foundation

enum MaidenheadLocator {
    private static let fieldLetters = Array("ABCDEFGHIJKLMNOPQR")
    private static let squareDigits = Array("0123456789")
    private static let subsquareLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWX")

    enum Precision: Int, Sendable {
        case field = 2
        case square = 4
        case subsquare = 6
        case extended = 8
    }

    struct DecodeResult: Sendable, Hashable {
        let latitude: Double
        let longitude: Double
        let precision: Precision
    }

    static func encode(latitude: Double, longitude: Double, precision: Precision = .subsquare) -> String {
        let lat = clamp(latitude, -90, 89.999999)
        let lon = clamp(longitude, -180, 179.999999)

        var adjLon = lon + 180
        var adjLat = lat + 90

        let lonField = Int(adjLon / 20)
        let latField = Int(adjLat / 10)
        var result = String(fieldLetters[lonField]) + String(fieldLetters[latField])

        adjLon -= Double(lonField) * 20
        adjLat -= Double(latField) * 10

        if precision.rawValue >= 4 {
            let lonSquare = Int(adjLon / 2)
            let latSquare = Int(adjLat / 1)
            result += String(squareDigits[lonSquare]) + String(squareDigits[latSquare])
            adjLon -= Double(lonSquare) * 2
            adjLat -= Double(latSquare) * 1
        }

        if precision.rawValue >= 6 {
            let lonSub = Int(adjLon / (2.0 / 24.0))
            let latSub = Int(adjLat / (1.0 / 24.0))
            result += String(subsquareLetters[lonSub]) + String(subsquareLetters[latSub])
            adjLon -= Double(lonSub) * (2.0 / 24.0)
            adjLat -= Double(latSub) * (1.0 / 24.0)
        }

        if precision.rawValue >= 8 {
            let lonExt = Int(adjLon / (2.0 / 24.0 / 24.0))
            let latExt = Int(adjLat / (1.0 / 24.0 / 24.0))
            result += String(squareDigits[min(lonExt, 9)]) + String(squareDigits[min(latExt, 9)])
        }

        return result.uppercased()
    }

    static func decode(_ grid: String) throws -> DecodeResult {
        let normalized = grid.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard normalized.count >= 2, normalized.count % 2 == 0, normalized.count <= 8 else {
            throw MaidenheadError.invalidLength
        }

        guard let lonField = fieldLetters.firstIndex(of: normalized[normalized.startIndex]),
              let latField = fieldLetters.firstIndex(of: normalized[normalized.index(normalized.startIndex, offsetBy: 1)]) else {
            throw MaidenheadError.invalidCharacters
        }

        var lon = Double(lonField) * 20 - 180 + 10
        var lat = Double(latField) * 10 - 90 + 5
        var precision = Precision.field

        if normalized.count >= 4 {
            let lonIdx = normalized.index(normalized.startIndex, offsetBy: 2)
            let latIdx = normalized.index(normalized.startIndex, offsetBy: 3)
            guard let lonSquare = squareDigits.firstIndex(of: normalized[lonIdx]),
                  let latSquare = squareDigits.firstIndex(of: normalized[latIdx]) else {
                throw MaidenheadError.invalidCharacters
            }
            lon = Double(lonField) * 20 - 180 + Double(lonSquare) * 2 + 1
            lat = Double(latField) * 10 - 90 + Double(latSquare) * 1 + 0.5
            precision = .square
        }

        if normalized.count >= 6 {
            let lonIdx = normalized.index(normalized.startIndex, offsetBy: 4)
            let latIdx = normalized.index(normalized.startIndex, offsetBy: 5)
            guard let lonSub = subsquareLetters.firstIndex(of: normalized[lonIdx]),
                  let latSub = subsquareLetters.firstIndex(of: normalized[latIdx]) else {
                throw MaidenheadError.invalidCharacters
            }
            let fieldLon = Double(lonField) * 20 - 180
            let fieldLat = Double(latField) * 10 - 90
            let squareLon = normalized.count >= 4 ? Double(squareDigits.firstIndex(of: normalized[normalized.index(normalized.startIndex, offsetBy: 2)])!) * 2 : 0
            let squareLat = normalized.count >= 4 ? Double(squareDigits.firstIndex(of: normalized[normalized.index(normalized.startIndex, offsetBy: 3)])!) * 1 : 0
            lon = fieldLon + squareLon + (Double(lonSub) + 0.5) * (2.0 / 24.0)
            lat = fieldLat + squareLat + (Double(latSub) + 0.5) * (1.0 / 24.0)
            precision = .subsquare
        }

        if normalized.count >= 8 {
            let lonIdx = normalized.index(normalized.startIndex, offsetBy: 6)
            let latIdx = normalized.index(normalized.startIndex, offsetBy: 7)
            guard let lonExt = squareDigits.firstIndex(of: normalized[lonIdx]),
                  let latExt = squareDigits.firstIndex(of: normalized[latIdx]) else {
                throw MaidenheadError.invalidCharacters
            }
            let subsquareLon = (2.0 / 24.0)
            let subsquareLat = (1.0 / 24.0)
            let fieldLon = Double(lonField) * 20 - 180
            let fieldLat = Double(latField) * 10 - 90
            let squareLon = Double(squareDigits.firstIndex(of: normalized[normalized.index(normalized.startIndex, offsetBy: 2)])!) * 2
            let squareLat = Double(squareDigits.firstIndex(of: normalized[normalized.index(normalized.startIndex, offsetBy: 3)])!) * 1
            let lonSub = Double(subsquareLetters.firstIndex(of: normalized[normalized.index(normalized.startIndex, offsetBy: 4)])!)
            let latSub = Double(subsquareLetters.firstIndex(of: normalized[normalized.index(normalized.startIndex, offsetBy: 5)])!)
            lon = fieldLon + squareLon + lonSub * subsquareLon + (Double(lonExt) + 0.5) * (subsquareLon / 24.0)
            lat = fieldLat + squareLat + latSub * subsquareLat + (Double(latExt) + 0.5) * (subsquareLat / 24.0)
            precision = .extended
        }

        return DecodeResult(latitude: lat, longitude: lon, precision: precision)
    }

    static func center(of grid: String) throws -> GeoCoordinate {
        let decoded = try decode(grid)
        return GeoCoordinate(latitude: decoded.latitude, longitude: decoded.longitude)
    }

    private static func clamp(_ value: Double, _ min: Double, _ max: Double) -> Double {
        Swift.max(min, Swift.min(max, value))
    }

    enum MaidenheadError: Error, Equatable {
        case invalidLength
        case invalidCharacters
    }
}
