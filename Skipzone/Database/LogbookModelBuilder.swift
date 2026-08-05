import CoreData
import Foundation

enum LogbookModelBuilder {
    static func makeModel() -> NSManagedObjectModel {
        let station = entity(
            LogbookEntityName.radioStation,
            className: NSStringFromClass(CDRadioStation.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("callsign", .stringAttributeType),
                attr("operatorName", .stringAttributeType),
                attr("gridSquare", .stringAttributeType),
                attr("latitude", .doubleAttributeType),
                attr("longitude", .doubleAttributeType),
                attr("countryCode", .stringAttributeType),
                attr("note", .stringAttributeType),
                attr("isHome", .booleanAttributeType),
                attr("createdAt", .dateAttributeType)
            ]
        )

        let contact = entity(
            LogbookEntityName.airContact,
            className: NSStringFromClass(CDAirContact.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("theirCallsign", .stringAttributeType),
                attr("theirGrid", .stringAttributeType),
                attr("theirLatitude", .doubleAttributeType),
                attr("theirLongitude", .doubleAttributeType),
                attr("bandRaw", .stringAttributeType),
                attr("modeRaw", .stringAttributeType),
                attr("frequencyKHz", .integer32AttributeType),
                attr("rstSent", .stringAttributeType),
                attr("rstReceived", .stringAttributeType),
                attr("qsoAt", .dateAttributeType),
                attr("antennaID", .UUIDAttributeType, optional: true),
                attr("note", .stringAttributeType),
                attr("stationID", .UUIDAttributeType, optional: true)
            ]
        )

        let band = entity(
            LogbookEntityName.bandSegment,
            className: NSStringFromClass(CDBandSegment.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("bandRaw", .stringAttributeType),
                attr("startMHz", .doubleAttributeType),
                attr("endMHz", .doubleAttributeType),
                attr("regionNote", .stringAttributeType)
            ]
        )

        let mode = entity(
            LogbookEntityName.modeSpec,
            className: NSStringFromClass(CDModeSpec.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("modeRaw", .stringAttributeType),
                attr("defaultPowerWatts", .integer32AttributeType),
                attr("note", .stringAttributeType)
            ]
        )

        let locator = entity(
            LogbookEntityName.gridLocator,
            className: NSStringFromClass(CDGridLocator.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("label", .stringAttributeType),
                attr("maidenhead", .stringAttributeType),
                attr("latitude", .doubleAttributeType),
                attr("longitude", .doubleAttributeType),
                attr("isFavorite", .booleanAttributeType)
            ]
        )

        let antenna = entity(
            LogbookEntityName.aerialRig,
            className: NSStringFromClass(CDAerialRig.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("name", .stringAttributeType),
                attr("kindRaw", .stringAttributeType),
                attr("bands", .stringAttributeType),
                attr("heightMeters", .doubleAttributeType),
                attr("note", .stringAttributeType),
                attr("isActive", .booleanAttributeType)
            ]
        )

        let prop = entity(
            LogbookEntityName.propNote,
            className: NSStringFromClass(CDPropNote.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("title", .stringAttributeType),
                attr("body", .stringAttributeType),
                attr("bandRaw", .stringAttributeType, optional: true),
                attr("recordedAt", .dateAttributeType),
                attr("kIndex", .integer16AttributeType),
                attr("sfi", .integer16AttributeType)
            ]
        )

        let profile = entity(
            LogbookEntityName.operatorProfile,
            className: NSStringFromClass(CDOperatorProfile.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("callsign", .stringAttributeType),
                attr("displayName", .stringAttributeType),
                attr("homeGrid", .stringAttributeType),
                attr("homeLatitude", .doubleAttributeType),
                attr("homeLongitude", .doubleAttributeType)
            ]
        )

        for entity in [station, contact, band, mode, locator, antenna, prop, profile] {
            entity.uniquenessConstraints = [["id"]]
        }

        let model = NSManagedObjectModel()
        model.entities = [station, contact, band, mode, locator, antenna, prop, profile]
        return model
    }

    private static func entity(
        _ name: String,
        className: String,
        attributes: [NSAttributeDescription]
    ) -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = className
        entity.properties = attributes
        return entity
    }

    private static func attr(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false
    ) -> NSAttributeDescription {
        let description = NSAttributeDescription()
        description.name = name
        description.attributeType = type
        description.isOptional = optional
        return description
    }
}
