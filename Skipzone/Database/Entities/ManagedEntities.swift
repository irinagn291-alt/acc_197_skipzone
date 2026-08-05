import CoreData
import Foundation

@objc(CDRadioStation)
final class CDRadioStation: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var callsign: String?
    @NSManaged var operatorName: String?
    @NSManaged var gridSquare: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var countryCode: String?
    @NSManaged var note: String?
    @NSManaged var isHome: Bool
    @NSManaged var createdAt: Date?
}

extension CDRadioStation {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDRadioStation> {
        NSFetchRequest<CDRadioStation>(entityName: LogbookEntityName.radioStation)
    }
}

@objc(CDAirContact)
final class CDAirContact: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var theirCallsign: String?
    @NSManaged var theirGrid: String?
    @NSManaged var theirLatitude: Double
    @NSManaged var theirLongitude: Double
    @NSManaged var bandRaw: String?
    @NSManaged var modeRaw: String?
    @NSManaged var frequencyKHz: Int32
    @NSManaged var rstSent: String?
    @NSManaged var rstReceived: String?
    @NSManaged var qsoAt: Date?
    @NSManaged var antennaID: UUID?
    @NSManaged var note: String?
    @NSManaged var stationID: UUID?
}

extension CDAirContact {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDAirContact> {
        NSFetchRequest<CDAirContact>(entityName: LogbookEntityName.airContact)
    }
}

@objc(CDBandSegment)
final class CDBandSegment: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var bandRaw: String?
    @NSManaged var startMHz: Double
    @NSManaged var endMHz: Double
    @NSManaged var regionNote: String?
}

extension CDBandSegment {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDBandSegment> {
        NSFetchRequest<CDBandSegment>(entityName: LogbookEntityName.bandSegment)
    }
}

@objc(CDModeSpec)
final class CDModeSpec: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var modeRaw: String?
    @NSManaged var defaultPowerWatts: Int32
    @NSManaged var note: String?
}

extension CDModeSpec {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDModeSpec> {
        NSFetchRequest<CDModeSpec>(entityName: LogbookEntityName.modeSpec)
    }
}

@objc(CDGridLocator)
final class CDGridLocator: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var label: String?
    @NSManaged var maidenhead: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var isFavorite: Bool
}

extension CDGridLocator {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDGridLocator> {
        NSFetchRequest<CDGridLocator>(entityName: LogbookEntityName.gridLocator)
    }
}

@objc(CDAerialRig)
final class CDAerialRig: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var kindRaw: String?
    @NSManaged var bands: String?
    @NSManaged var heightMeters: Double
    @NSManaged var note: String?
    @NSManaged var isActive: Bool
}

extension CDAerialRig {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDAerialRig> {
        NSFetchRequest<CDAerialRig>(entityName: LogbookEntityName.aerialRig)
    }
}

@objc(CDPropNote)
final class CDPropNote: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var title: String?
    @NSManaged var body: String?
    @NSManaged var bandRaw: String?
    @NSManaged var recordedAt: Date?
    @NSManaged var kIndex: Int16
    @NSManaged var sfi: Int16
}

extension CDPropNote {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDPropNote> {
        NSFetchRequest<CDPropNote>(entityName: LogbookEntityName.propNote)
    }
}

@objc(CDOperatorProfile)
final class CDOperatorProfile: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var callsign: String?
    @NSManaged var displayName: String?
    @NSManaged var homeGrid: String?
    @NSManaged var homeLatitude: Double
    @NSManaged var homeLongitude: Double
}

extension CDOperatorProfile {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDOperatorProfile> {
        NSFetchRequest<CDOperatorProfile>(entityName: LogbookEntityName.operatorProfile)
    }
}
