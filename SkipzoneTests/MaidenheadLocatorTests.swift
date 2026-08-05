import XCTest
@testable import Skipzone

final class MaidenheadLocatorTests: XCTestCase {
    func testRoundTripFourChar() throws {
        let grid = MaidenheadLocator.encode(latitude: 41.71, longitude: -72.73, precision: .square)
        XCTAssertEqual(grid.count, 4)
        let decoded = try MaidenheadLocator.decode(grid)
        XCTAssertEqual(decoded.latitude, 41.5, accuracy: 1.0)
        XCTAssertEqual(decoded.longitude, -73.0, accuracy: 1.0)
    }

    func testRoundTripSixChar() throws {
        let original = GeoCoordinate(latitude: 51.5, longitude: -0.1)
        let grid = MaidenheadLocator.encode(
            latitude: original.latitude,
            longitude: original.longitude,
            precision: .subsquare
        )
        XCTAssertEqual(grid.count, 6)
        let decoded = try MaidenheadLocator.decode(grid)
        XCTAssertEqual(decoded.latitude, original.latitude, accuracy: 0.05)
        XCTAssertEqual(decoded.longitude, original.longitude, accuracy: 0.05)
    }

    func testKnownGridFN31() throws {
        let decoded = try MaidenheadLocator.decode("FN31")
        XCTAssertEqual(decoded.latitude, 41.5, accuracy: 1.0)
        XCTAssertEqual(decoded.longitude, -73.0, accuracy: 1.0)
    }

    func testInvalidGridThrows() {
        XCTAssertThrowsError(try MaidenheadLocator.decode("X"))
    }
}
