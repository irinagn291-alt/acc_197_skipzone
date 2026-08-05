import XCTest
@testable import Skipzone

final class GreatCircleSolverTests: XCTestCase {
    func testLondonToParis() {
        let london = GeoCoordinate(latitude: 51.5074, longitude: -0.1278)
        let paris = GeoCoordinate(latitude: 48.8566, longitude: 2.3522)
        let distance = GreatCircleSolver.haversineDistanceKm(from: london, to: paris)
        XCTAssertEqual(distance, 344, accuracy: 15)
    }

    func testNewYorkToLondon() {
        let ny = GeoCoordinate(latitude: 40.7128, longitude: -74.0060)
        let london = GeoCoordinate(latitude: 51.5074, longitude: -0.1278)
        let distance = GreatCircleSolver.haversineDistanceKm(from: ny, to: london)
        XCTAssertEqual(distance, 5570, accuracy: 100)
    }

    func testBearingEastward() {
        let origin = GeoCoordinate(latitude: 0, longitude: 0)
        let east = GeoCoordinate(latitude: 0, longitude: 10)
        let bearing = GreatCircleSolver.initialBearingDegrees(from: origin, to: east)
        XCTAssertEqual(bearing, 90, accuracy: 1)
    }

    func testLongPathComplement() {
        let a = GeoCoordinate(latitude: 40, longitude: -74)
        let b = GeoCoordinate(latitude: 51, longitude: 0)
        let short = GreatCircleSolver.haversineDistanceKm(from: a, to: b)
        let long = GreatCircleSolver.longPath(from: a, to: b)
        XCTAssertEqual(short + long.distanceKm, 2 * .pi * 6371, accuracy: 5)
    }

    func testTerminatorProducesPoints() {
        let geometry = GreatCircleSolver.solarGeometry(for: Date())
        XCTAssertGreaterThan(geometry.terminatorPoints.count, 10)
        XCTAssertFalse(geometry.terminatorPoints.allSatisfy { $0.latitude == 0 })
    }
}
