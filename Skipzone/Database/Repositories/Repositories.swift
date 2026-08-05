import CoreData
import Foundation

@MainActor
final class SkipContactRepository {
    private let vault: LogbookVault

    init(vault: LogbookVault) { self.vault = vault }

    func fetchAll() throws -> [AirContact] {
        let request = CDAirContact.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "qsoAt", ascending: false)]
        return try vault.viewContext.fetch(request).map(SkipEntityMapping.contact)
    }

    func fetch(id: UUID) throws -> AirContact? {
        let request = CDAirContact.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try vault.viewContext.fetch(request).first.map(SkipEntityMapping.contact)
    }

    func upsert(_ item: AirContact) async throws {
        try await vault.perform { context in
            let request = CDAirContact.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            let object = try context.fetch(request).first ?? CDAirContact(context: context)
            SkipEntityMapping.apply(item, to: object)
            try context.save()
        }
    }

    func delete(id: UUID) async throws {
        try await vault.perform { context in
            let request = CDAirContact.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            for object in try context.fetch(request) { context.delete(object) }
            try context.save()
        }
    }

    func deleteAll() async throws {
        try await vault.perform { context in
            let request = CDAirContact.fetchRequest()
            for object in try context.fetch(request) { context.delete(object) }
            try context.save()
        }
    }
}

@MainActor
final class StationRepository {
    private let vault: LogbookVault

    init(vault: LogbookVault) { self.vault = vault }

    func fetchAll() throws -> [RadioStation] {
        let request = CDRadioStation.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "callsign", ascending: true)]
        return try vault.viewContext.fetch(request).map(SkipEntityMapping.station)
    }

    func fetchHome() throws -> RadioStation? {
        let request = CDRadioStation.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "isHome == YES")
        return try vault.viewContext.fetch(request).first.map(SkipEntityMapping.station)
    }

    func upsert(_ item: RadioStation) async throws {
        try await vault.perform { context in
            if item.isHome {
                let homeRequest = CDRadioStation.fetchRequest()
                homeRequest.predicate = NSPredicate(format: "isHome == YES")
                for existing in try context.fetch(homeRequest) where existing.id != item.id {
                    existing.isHome = false
                }
            }
            let request = CDRadioStation.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            let object = try context.fetch(request).first ?? CDRadioStation(context: context)
            SkipEntityMapping.apply(item, to: object)
            try context.save()
        }
    }

    func delete(id: UUID) async throws {
        try await vault.perform { context in
            let request = CDRadioStation.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            for object in try context.fetch(request) { context.delete(object) }
            try context.save()
        }
    }
}

@MainActor
final class AntennaRepository {
    private let vault: LogbookVault

    init(vault: LogbookVault) { self.vault = vault }

    func fetchAll() throws -> [AerialRig] {
        let request = CDAerialRig.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try vault.viewContext.fetch(request).map(SkipEntityMapping.antenna)
    }

    func upsert(_ item: AerialRig) async throws {
        try await vault.perform { context in
            let request = CDAerialRig.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            let object = try context.fetch(request).first ?? CDAerialRig(context: context)
            SkipEntityMapping.apply(item, to: object)
            try context.save()
        }
    }

    func delete(id: UUID) async throws {
        try await vault.perform { context in
            let request = CDAerialRig.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            for object in try context.fetch(request) { context.delete(object) }
            try context.save()
        }
    }
}

@MainActor
final class PropNoteRepository {
    private let vault: LogbookVault

    init(vault: LogbookVault) { self.vault = vault }

    func fetchAll() throws -> [PropNote] {
        let request = CDPropNote.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "recordedAt", ascending: false)]
        return try vault.viewContext.fetch(request).map(SkipEntityMapping.propNote)
    }

    func upsert(_ item: PropNote) async throws {
        try await vault.perform { context in
            let request = CDPropNote.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            let object = try context.fetch(request).first ?? CDPropNote(context: context)
            SkipEntityMapping.apply(item, to: object)
            try context.save()
        }
    }

    func delete(id: UUID) async throws {
        try await vault.perform { context in
            let request = CDPropNote.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            for object in try context.fetch(request) { context.delete(object) }
            try context.save()
        }
    }
}

@MainActor
final class SkipProfileRepository {
    private let vault: LogbookVault

    init(vault: LogbookVault) { self.vault = vault }

    func fetch() throws -> OperatorProfile? {
        let request = CDOperatorProfile.fetchRequest()
        request.fetchLimit = 1
        return try vault.viewContext.fetch(request).first.map(SkipEntityMapping.profile)
    }

    func upsert(_ item: OperatorProfile) async throws {
        try await vault.perform { context in
            let request = CDOperatorProfile.fetchRequest()
            request.fetchLimit = 1
            let object = try context.fetch(request).first ?? CDOperatorProfile(context: context)
            SkipEntityMapping.apply(item, to: object)
            try context.save()
        }
    }
}

@MainActor
final class BandSegmentRepository {
    private let vault: LogbookVault

    init(vault: LogbookVault) { self.vault = vault }

    func fetchAll() throws -> [BandSegment] {
        let request = CDBandSegment.fetchRequest()
        return try vault.viewContext.fetch(request).map(SkipEntityMapping.bandSegment)
    }

    func upsert(_ item: BandSegment) async throws {
        try await vault.perform { context in
            let request = CDBandSegment.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            let object = try context.fetch(request).first ?? CDBandSegment(context: context)
            SkipEntityMapping.apply(item, to: object)
            try context.save()
        }
    }
}

@MainActor
final class LocatorRepository {
    private let vault: LogbookVault

    init(vault: LogbookVault) { self.vault = vault }

    func fetchAll() throws -> [GridLocator] {
        let request = CDGridLocator.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
        return try vault.viewContext.fetch(request).map(SkipEntityMapping.locator)
    }

    func upsert(_ item: GridLocator) async throws {
        try await vault.perform { context in
            let request = CDGridLocator.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            let object = try context.fetch(request).first ?? CDGridLocator(context: context)
            SkipEntityMapping.apply(item, to: object)
            try context.save()
        }
    }
}
