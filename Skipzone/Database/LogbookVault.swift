import CoreData
import Foundation

enum LogbookVaultError: LocalizedError, Equatable {
    case storeFailure(String)

    var errorDescription: String? {
        switch self {
        case .storeFailure(let reason):
            "The logbook database could not be opened. \(reason)"
        }
    }
}

final class LogbookVault: @unchecked Sendable {
    enum SkipStoreLocation: Sendable {
        case onDisk
        case inMemory
    }

    nonisolated(unsafe) private static let sharedModel: NSManagedObjectModel = LogbookModelBuilder.makeModel()

    let container: NSPersistentContainer
    private(set) var startupError: LogbookVaultError?

    var viewContext: NSManagedObjectContext { container.viewContext }
    var isReady: Bool { startupError == nil }

    init(location: SkipStoreLocation = .onDisk) {
        container = NSPersistentContainer(name: "Skipzone", managedObjectModel: Self.sharedModel)

        let description: NSPersistentStoreDescription
        switch location {
        case .inMemory:
            description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
        case .onDisk:
            description = NSPersistentStoreDescription(url: Self.storeURL)
            description.type = NSSQLiteStoreType
        }
        description.shouldAddStoreAsynchronously = false
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        if let error = Self.loadStores(into: container) {
            if location == .onDisk {
                try? FileManager.default.removeItem(at: Self.storeURL)
                if let retry = Self.loadStores(into: container) {
                    startupError = .storeFailure(retry.localizedDescription)
                }
            } else {
                startupError = .storeFailure(error.localizedDescription)
            }
        }

        Self.tune(container.viewContext)
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        Self.tune(context)
        return context
    }

    func perform<T: Sendable>(
        _ body: @escaping @Sendable (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        let context = newBackgroundContext()
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    continuation.resume(returning: try body(context))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    static var storeURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = support.appendingPathComponent("Skipzone", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("skipzone.sqlite")
    }

    private static func loadStores(into container: NSPersistentContainer) -> Error? {
        var captured: Error?
        container.loadPersistentStores { _, error in
            if let error { captured = error }
        }
        return captured
    }

    private static func tune(_ context: NSManagedObjectContext) {
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
}
