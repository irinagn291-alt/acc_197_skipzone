import XCTest
@testable import Skipzone

@MainActor
final class LogbookVaultTests: XCTestCase {
    var vault: LogbookVault!
    var contacts: SkipContactRepository!
    var stations: StationRepository!
    var profile: SkipProfileRepository!

    override func setUp() async throws {
        vault = LogbookVault(location: .inMemory)
        contacts = SkipContactRepository(vault: vault)
        stations = StationRepository(vault: vault)
        profile = SkipProfileRepository(vault: vault)
    }

    func testContactCRUD() async throws {
        let contact = AirContact(
            id: UUID(),
            theirCallsign: "G3XYZ",
            theirGrid: "IO91",
            theirLatitude: 51.5,
            theirLongitude: -1.0,
            band: .m20,
            mode: .ssb,
            frequencyKHz: 14200,
            rstSent: "59",
            rstReceived: "59",
            qsoAt: Date(),
            antennaID: nil,
            note: "Test",
            stationID: nil
        )
        try await contacts.upsert(contact)
        let fetched = try contacts.fetchAll()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.theirCallsign, "G3XYZ")

        try await contacts.delete(id: contact.id)
        let afterDelete = try contacts.fetchAll()
        XCTAssertTrue(afterDelete.isEmpty)
    }

    func testStationHomeFlag() async throws {
        let home = RadioStation(
            id: UUID(),
            callsign: "W1AW",
            operatorName: "Test",
            gridSquare: "FN31",
            latitude: 41.5,
            longitude: -73.0,
            countryCode: "US",
            note: "",
            isHome: true,
            createdAt: Date()
        )
        try await stations.upsert(home)
        let fetched = try stations.fetchHome()
        XCTAssertEqual(fetched?.callsign, "W1AW")
    }

    func testProfileUpsert() async throws {
        let item = OperatorProfile(
            id: UUID(),
            callsign: "K1ABC",
            displayName: "Tester",
            homeGrid: "FN31",
            homeLatitude: 41.5,
            homeLongitude: -73.0
        )
        try await profile.upsert(item)
        let fetched = try profile.fetch()
        XCTAssertEqual(fetched?.callsign, "K1ABC")
    }
}
