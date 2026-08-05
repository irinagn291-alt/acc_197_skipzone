import CoreData
import Foundation

enum SkipEntityMapping {
    static func station(_ object: CDRadioStation) -> RadioStation {
        RadioStation(
            id: object.id ?? UUID(),
            callsign: object.callsign ?? "",
            operatorName: object.operatorName ?? "",
            gridSquare: object.gridSquare ?? "",
            latitude: object.latitude,
            longitude: object.longitude,
            countryCode: object.countryCode ?? "",
            note: object.note ?? "",
            isHome: object.isHome,
            createdAt: object.createdAt ?? Date()
        )
    }

    static func apply(_ item: RadioStation, to object: CDRadioStation) {
        object.id = item.id
        object.callsign = item.callsign
        object.operatorName = item.operatorName
        object.gridSquare = item.gridSquare
        object.latitude = item.latitude
        object.longitude = item.longitude
        object.countryCode = item.countryCode
        object.note = item.note
        object.isHome = item.isHome
        object.createdAt = item.createdAt
    }

    static func contact(_ object: CDAirContact) -> AirContact {
        AirContact(
            id: object.id ?? UUID(),
            theirCallsign: object.theirCallsign ?? "",
            theirGrid: object.theirGrid ?? "",
            theirLatitude: object.theirLatitude,
            theirLongitude: object.theirLongitude,
            band: RadioBand(rawValue: object.bandRaw ?? "") ?? .m20,
            mode: RadioMode(rawValue: object.modeRaw ?? "") ?? .ssb,
            frequencyKHz: Int(object.frequencyKHz),
            rstSent: object.rstSent ?? "",
            rstReceived: object.rstReceived ?? "",
            qsoAt: object.qsoAt ?? Date(),
            antennaID: object.antennaID,
            note: object.note ?? "",
            stationID: object.stationID
        )
    }

    static func apply(_ item: AirContact, to object: CDAirContact) {
        object.id = item.id
        object.theirCallsign = item.theirCallsign
        object.theirGrid = item.theirGrid
        object.theirLatitude = item.theirLatitude
        object.theirLongitude = item.theirLongitude
        object.bandRaw = item.band.rawValue
        object.modeRaw = item.mode.rawValue
        object.frequencyKHz = Int32(item.frequencyKHz)
        object.rstSent = item.rstSent
        object.rstReceived = item.rstReceived
        object.qsoAt = item.qsoAt
        object.antennaID = item.antennaID
        object.note = item.note
        object.stationID = item.stationID
    }

    static func bandSegment(_ object: CDBandSegment) -> BandSegment {
        BandSegment(
            id: object.id ?? UUID(),
            band: RadioBand(rawValue: object.bandRaw ?? "") ?? .m20,
            startMHz: object.startMHz,
            endMHz: object.endMHz,
            regionNote: object.regionNote ?? ""
        )
    }

    static func apply(_ item: BandSegment, to object: CDBandSegment) {
        object.id = item.id
        object.bandRaw = item.band.rawValue
        object.startMHz = item.startMHz
        object.endMHz = item.endMHz
        object.regionNote = item.regionNote
    }

    static func modeSpec(_ object: CDModeSpec) -> ModeSpec {
        ModeSpec(
            id: object.id ?? UUID(),
            mode: RadioMode(rawValue: object.modeRaw ?? "") ?? .ssb,
            defaultPowerWatts: Int(object.defaultPowerWatts),
            note: object.note ?? ""
        )
    }

    static func apply(_ item: ModeSpec, to object: CDModeSpec) {
        object.id = item.id
        object.modeRaw = item.mode.rawValue
        object.defaultPowerWatts = Int32(item.defaultPowerWatts)
        object.note = item.note
    }

    static func locator(_ object: CDGridLocator) -> GridLocator {
        GridLocator(
            id: object.id ?? UUID(),
            label: object.label ?? "",
            maidenhead: object.maidenhead ?? "",
            latitude: object.latitude,
            longitude: object.longitude,
            isFavorite: object.isFavorite
        )
    }

    static func apply(_ item: GridLocator, to object: CDGridLocator) {
        object.id = item.id
        object.label = item.label
        object.maidenhead = item.maidenhead
        object.latitude = item.latitude
        object.longitude = item.longitude
        object.isFavorite = item.isFavorite
    }

    static func antenna(_ object: CDAerialRig) -> AerialRig {
        AerialRig(
            id: object.id ?? UUID(),
            name: object.name ?? "",
            kind: AntennaKind(rawValue: object.kindRaw ?? "") ?? .dipole,
            bands: object.bands ?? "",
            heightMeters: object.heightMeters,
            note: object.note ?? "",
            isActive: object.isActive
        )
    }

    static func apply(_ item: AerialRig, to object: CDAerialRig) {
        object.id = item.id
        object.name = item.name
        object.kindRaw = item.kind.rawValue
        object.bands = item.bands
        object.heightMeters = item.heightMeters
        object.note = item.note
        object.isActive = item.isActive
    }

    static func propNote(_ object: CDPropNote) -> PropNote {
        PropNote(
            id: object.id ?? UUID(),
            title: object.title ?? "",
            body: object.body ?? "",
            band: object.bandRaw.flatMap(RadioBand.init(rawValue:)),
            recordedAt: object.recordedAt ?? Date(),
            kIndex: object.kIndex >= 0 ? Int(object.kIndex) : nil,
            sfi: object.sfi >= 0 ? Int(object.sfi) : nil
        )
    }

    static func apply(_ item: PropNote, to object: CDPropNote) {
        object.id = item.id
        object.title = item.title
        object.body = item.body
        object.bandRaw = item.band?.rawValue
        object.recordedAt = item.recordedAt
        object.kIndex = Int16(item.kIndex ?? -1)
        object.sfi = Int16(item.sfi ?? -1)
    }

    static func profile(_ object: CDOperatorProfile) -> OperatorProfile {
        OperatorProfile(
            id: object.id ?? UUID(),
            callsign: object.callsign ?? "",
            displayName: object.displayName ?? "",
            homeGrid: object.homeGrid ?? "",
            homeLatitude: object.homeLatitude,
            homeLongitude: object.homeLongitude
        )
    }

    static func apply(_ item: OperatorProfile, to object: CDOperatorProfile) {
        object.id = item.id
        object.callsign = item.callsign
        object.displayName = item.displayName
        object.homeGrid = item.homeGrid
        object.homeLatitude = item.homeLatitude
        object.homeLongitude = item.homeLongitude
    }
}
