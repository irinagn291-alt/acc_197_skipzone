import Foundation

enum RadioBand: String, Codable, CaseIterable, Sendable {
    case m160, m80, m60, m40, m30, m20, m17, m15, m12, m10, m6, vhf, uhf

    var label: String {
        switch self {
        case .m160: "160m"
        case .m80: "80m"
        case .m60: "60m"
        case .m40: "40m"
        case .m30: "30m"
        case .m20: "20m"
        case .m17: "17m"
        case .m15: "15m"
        case .m12: "12m"
        case .m10: "10m"
        case .m6: "6m"
        case .vhf: "VHF"
        case .uhf: "UHF"
        }
    }

    var frequencyMHz: Double {
        switch self {
        case .m160: 1.9
        case .m80: 3.7
        case .m60: 5.4
        case .m40: 7.1
        case .m30: 10.1
        case .m20: 14.2
        case .m17: 18.1
        case .m15: 21.2
        case .m12: 24.9
        case .m10: 28.5
        case .m6: 50.3
        case .vhf: 144.0
        case .uhf: 432.0
        }
    }
}

enum RadioMode: String, Codable, CaseIterable, Sendable {
    case cw, ssb, am, fm, digital, ft8, rtty

    var label: String { rawValue.uppercased() }
}

enum AntennaKind: String, Codable, CaseIterable, Sendable {
    case dipole, vertical, yagi, loop, wire, other

    var label: String { rawValue.capitalized }
}

struct RadioStation: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var callsign: String
    var operatorName: String
    var gridSquare: String
    var latitude: Double
    var longitude: Double
    var countryCode: String
    var note: String
    var isHome: Bool
    var createdAt: Date
}

struct AirContact: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var theirCallsign: String
    var theirGrid: String
    var theirLatitude: Double
    var theirLongitude: Double
    var band: RadioBand
    var mode: RadioMode
    var frequencyKHz: Int
    var rstSent: String
    var rstReceived: String
    var qsoAt: Date
    var antennaID: UUID?
    var note: String
    var stationID: UUID?
}

struct BandSegment: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var band: RadioBand
    var startMHz: Double
    var endMHz: Double
    var regionNote: String
}

struct ModeSpec: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var mode: RadioMode
    var defaultPowerWatts: Int
    var note: String
}

struct GridLocator: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var label: String
    var maidenhead: String
    var latitude: Double
    var longitude: Double
    var isFavorite: Bool
}

struct AerialRig: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var name: String
    var kind: AntennaKind
    var bands: String
    var heightMeters: Double
    var note: String
    var isActive: Bool
}

struct PropNote: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var band: RadioBand?
    var recordedAt: Date
    var kIndex: Int?
    var sfi: Int?
}

struct OperatorProfile: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var callsign: String
    var displayName: String
    var homeGrid: String
    var homeLatitude: Double
    var homeLongitude: Double
}

struct BandHourCell: Sendable, Hashable {
    let band: RadioBand
    let hour: Int
    let count: Int
}

struct GreatCircleRoute: Sendable, Hashable {
    let distanceKm: Double
    let initialBearingDegrees: Double
    let longPathDistanceKm: Double
    let longPathBearingDegrees: Double
    let pathPoints: [GeoCoordinate]
}

struct GeoCoordinate: Sendable, Hashable {
    let latitude: Double
    let longitude: Double
}

struct SolarGeometry: Sendable, Hashable {
    let declinationDegrees: Double
    let hourAngleDegrees: Double
    let terminatorPoints: [GeoCoordinate]
}

struct SkipBackupPayload: Codable, Sendable {
    static let currentVersion = 1

    var version: Int
    var exportedAt: Date
    var profile: OperatorProfile?
    var stations: [RadioStation]
    var contacts: [AirContact]
    var bandSegments: [BandSegment]
    var modeSpecs: [ModeSpec]
    var locators: [GridLocator]
    var antennas: [AerialRig]
    var propNotes: [PropNote]
}
