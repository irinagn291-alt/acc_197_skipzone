import XCTest
@testable import Skipzone

@MainActor
final class BackupRoundTripTests: XCTestCase {
    func testExportImportRoundTrip() async throws {
        let vault = LogbookVault(location: .inMemory)
        let contacts = SkipContactRepository(vault: vault)
        let profile = SkipProfileRepository(vault: vault)
        let backup = SkipBackupService(vault: vault)

        let profileItem = OperatorProfile(
            id: UUID(),
            callsign: "W1AW",
            displayName: "Demo",
            homeGrid: "FN31pr",
            homeLatitude: 41.71,
            homeLongitude: -72.73
        )
        try await profile.upsert(profileItem)

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
            note: "",
            stationID: nil
        )
        try await contacts.upsert(contact)

        let json = try await backup.exportJSON()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(SkipBackupPayload.self, from: json)
        XCTAssertEqual(payload.version, SkipBackupPayload.currentVersion)
        XCTAssertEqual(payload.contacts.count, 1)
        XCTAssertEqual(payload.profile?.callsign, "W1AW")

        try await contacts.deleteAll()
        XCTAssertTrue(try contacts.fetchAll().isEmpty)

        try await backup.restore(from: json)
        let restored = try contacts.fetchAll()
        XCTAssertEqual(restored.count, 1)
        XCTAssertEqual(restored.first?.theirCallsign, "G3XYZ")
    }

    func testMalformedBackupRejected() async throws {
        let vault = LogbookVault(location: .inMemory)
        let backup = SkipBackupService(vault: vault)
        let badData = Data("{ not valid json".utf8)
        do {
            try await backup.restore(from: badData)
            XCTFail("Expected decode error")
        } catch {
            XCTAssertTrue(true)
        }
    }
}
