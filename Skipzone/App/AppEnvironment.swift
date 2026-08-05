import Foundation
import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    let vault: LogbookVault
    let contactsRepo: SkipContactRepository
    let stationsRepo: StationRepository
    let antennasRepo: AntennaRepository
    let propNotesRepo: PropNoteRepository
    let profileRepo: SkipProfileRepository
    let bandSegmentsRepo: BandSegmentRepository
    let locatorsRepo: LocatorRepository
    let backup: SkipBackupService

    @Published private(set) var isReady = false
    @Published private(set) var bootstrapError: String?
    @Published var operatorProfile: OperatorProfile?
    @Published var contacts: [AirContact] = []
    @Published var antennas: [AerialRig] = []
    @Published var propNotes: [PropNote] = []
    @Published var stations: [RadioStation] = []

    static func live() -> AppEnvironment {
        let vault = LogbookVault(location: .onDisk)
        if let error = vault.startupError {
            let fallback = LogbookVault(location: .inMemory)
            return AppEnvironment(vault: fallback, bootstrapError: error.errorDescription)
        }
        return AppEnvironment(vault: vault)
    }

    init(vault: LogbookVault, bootstrapError: String? = nil) {
        self.vault = vault
        self.bootstrapError = bootstrapError
        self.contactsRepo = SkipContactRepository(vault: vault)
        self.stationsRepo = StationRepository(vault: vault)
        self.antennasRepo = AntennaRepository(vault: vault)
        self.propNotesRepo = PropNoteRepository(vault: vault)
        self.profileRepo = SkipProfileRepository(vault: vault)
        self.bandSegmentsRepo = BandSegmentRepository(vault: vault)
        self.locatorsRepo = LocatorRepository(vault: vault)
        self.backup = SkipBackupService(vault: vault)
    }

    func bootstrap() async {
        do {
            operatorProfile = try profileRepo.fetch()
            #if targetEnvironment(simulator)
            try await SkipSeedService.seedIfNeeded(
                contacts: contactsRepo,
                stations: stationsRepo,
                antennas: antennasRepo,
                profile: profileRepo,
                existingProfile: operatorProfile
            )
            operatorProfile = try profileRepo.fetch()
            if operatorProfile != nil {
                UserDefaults.standard.set(true, forKey: SkipDefaults.onboardingCompleted)
            }
            #endif
            await reloadAll()
            isReady = true
        } catch {
            bootstrapError = error.localizedDescription
            isReady = true
        }
    }

    func reloadAll() async {
        await reloadContacts()
        antennas = (try? antennasRepo.fetchAll()) ?? []
        propNotes = (try? propNotesRepo.fetchAll()) ?? []
        stations = (try? stationsRepo.fetchAll()) ?? []
        operatorProfile = try? profileRepo.fetch()
    }

    func reloadContacts() async {
        contacts = (try? contactsRepo.fetchAll()) ?? []
    }

    func completeOnboarding(
        callsign: String,
        displayName: String,
        homeGrid: String
    ) async throws {
        let coords = try MaidenheadLocator.decode(homeGrid)
        let profile = OperatorProfile(
            id: operatorProfile?.id ?? UUID(),
            callsign: callsign.uppercased(),
            displayName: displayName,
            homeGrid: homeGrid.uppercased(),
            homeLatitude: coords.latitude,
            homeLongitude: coords.longitude
        )
        try await profileRepo.upsert(profile)
        operatorProfile = profile

        let station = RadioStation(
            id: UUID(),
            callsign: callsign.uppercased(),
            operatorName: displayName,
            gridSquare: homeGrid.uppercased(),
            latitude: coords.latitude,
            longitude: coords.longitude,
            countryCode: "",
            note: "Home station",
            isHome: true,
            createdAt: Date()
        )
        try await stationsRepo.upsert(station)

        UserDefaults.standard.set(true, forKey: SkipDefaults.onboardingCompleted)
        await reloadAll()
    }

    var onboardingCompleted: Bool {
        UserDefaults.standard.bool(forKey: SkipDefaults.onboardingCompleted)
    }
}
