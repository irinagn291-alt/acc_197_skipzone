import CoreData
import Foundation

struct SkipBackupService: Sendable {
    let vault: LogbookVault

    init(vault: LogbookVault) {
        self.vault = vault
    }

    func exportPayload() async throws -> SkipBackupPayload {
        try await vault.perform { context in
            SkipBackupPayload(
                version: SkipBackupPayload.currentVersion,
                exportedAt: Date(),
                profile: try Self.fetchProfile(context),
                stations: try Self.fetchStations(context),
                contacts: try Self.fetchContacts(context),
                bandSegments: try Self.fetchBandSegments(context),
                modeSpecs: try Self.fetchModeSpecs(context),
                locators: try Self.fetchLocators(context),
                antennas: try Self.fetchAntennas(context),
                propNotes: try Self.fetchPropNotes(context)
            )
        }
    }

    func exportJSON() async throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(try await exportPayload())
    }

    func restore(from data: Data) async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(SkipBackupPayload.self, from: data)
        guard payload.version <= SkipBackupPayload.currentVersion else {
            throw SkipBackupError.unsupportedVersion
        }

        try await vault.perform { context in
            try Self.deleteAll(context)
            if let profile = payload.profile {
                let object = CDOperatorProfile(context: context)
                SkipEntityMapping.apply(profile, to: object)
            }
            for station in payload.stations {
                let object = CDRadioStation(context: context)
                SkipEntityMapping.apply(station, to: object)
            }
            for contact in payload.contacts {
                let object = CDAirContact(context: context)
                SkipEntityMapping.apply(contact, to: object)
            }
            for segment in payload.bandSegments {
                let object = CDBandSegment(context: context)
                SkipEntityMapping.apply(segment, to: object)
            }
            for spec in payload.modeSpecs {
                let object = CDModeSpec(context: context)
                SkipEntityMapping.apply(spec, to: object)
            }
            for locator in payload.locators {
                let object = CDGridLocator(context: context)
                SkipEntityMapping.apply(locator, to: object)
            }
            for antenna in payload.antennas {
                let object = CDAerialRig(context: context)
                SkipEntityMapping.apply(antenna, to: object)
            }
            for note in payload.propNotes {
                let object = CDPropNote(context: context)
                SkipEntityMapping.apply(note, to: object)
            }
            try context.save()
        }
    }

    private static func deleteAll(_ context: NSManagedObjectContext) throws {
        for object in try context.fetch(CDPropNote.fetchRequest()) { context.delete(object) }
        for object in try context.fetch(CDAerialRig.fetchRequest()) { context.delete(object) }
        for object in try context.fetch(CDGridLocator.fetchRequest()) { context.delete(object) }
        for object in try context.fetch(CDModeSpec.fetchRequest()) { context.delete(object) }
        for object in try context.fetch(CDBandSegment.fetchRequest()) { context.delete(object) }
        for object in try context.fetch(CDAirContact.fetchRequest()) { context.delete(object) }
        for object in try context.fetch(CDRadioStation.fetchRequest()) { context.delete(object) }
        for object in try context.fetch(CDOperatorProfile.fetchRequest()) { context.delete(object) }
    }

    private static func fetchProfile(_ context: NSManagedObjectContext) throws -> OperatorProfile? {
        let request = CDOperatorProfile.fetchRequest()
        request.fetchLimit = 1
        return try context.fetch(request).first.map(SkipEntityMapping.profile)
    }

    private static func fetchStations(_ context: NSManagedObjectContext) throws -> [RadioStation] {
        try context.fetch(CDRadioStation.fetchRequest()).map(SkipEntityMapping.station)
    }

    private static func fetchContacts(_ context: NSManagedObjectContext) throws -> [AirContact] {
        try context.fetch(CDAirContact.fetchRequest()).map(SkipEntityMapping.contact)
    }

    private static func fetchBandSegments(_ context: NSManagedObjectContext) throws -> [BandSegment] {
        try context.fetch(CDBandSegment.fetchRequest()).map(SkipEntityMapping.bandSegment)
    }

    private static func fetchModeSpecs(_ context: NSManagedObjectContext) throws -> [ModeSpec] {
        try context.fetch(CDModeSpec.fetchRequest()).map(SkipEntityMapping.modeSpec)
    }

    private static func fetchLocators(_ context: NSManagedObjectContext) throws -> [GridLocator] {
        try context.fetch(CDGridLocator.fetchRequest()).map(SkipEntityMapping.locator)
    }

    private static func fetchAntennas(_ context: NSManagedObjectContext) throws -> [AerialRig] {
        try context.fetch(CDAerialRig.fetchRequest()).map(SkipEntityMapping.antenna)
    }

    private static func fetchPropNotes(_ context: NSManagedObjectContext) throws -> [PropNote] {
        try context.fetch(CDPropNote.fetchRequest()).map(SkipEntityMapping.propNote)
    }

    enum SkipBackupError: Error, Equatable {
        case unsupportedVersion
    }
}
