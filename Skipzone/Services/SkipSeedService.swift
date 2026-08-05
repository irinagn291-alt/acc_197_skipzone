import Foundation

enum SkipSeedService {
    static func seedIfNeeded(
        contacts: SkipContactRepository,
        stations: StationRepository,
        antennas: AntennaRepository,
        profile: SkipProfileRepository,
        existingProfile: OperatorProfile?
    ) async throws {
        guard existingProfile == nil else { return }

        let homeID = UUID()
        let profileItem = OperatorProfile(
            id: UUID(),
            callsign: "W1AW",
            displayName: "Demo Operator",
            homeGrid: "FN31pr",
            homeLatitude: 41.71,
            homeLongitude: -72.73
        )
        try await profile.upsert(profileItem)

        let homeStation = RadioStation(
            id: homeID,
            callsign: "W1AW",
            operatorName: "Demo Operator",
            gridSquare: "FN31pr",
            latitude: 41.71,
            longitude: -72.73,
            countryCode: "US",
            note: "Home station",
            isHome: true,
            createdAt: Date()
        )
        try await stations.upsert(homeStation)

        let antennaID = UUID()
        try await antennas.upsert(AerialRig(
            id: antennaID,
            name: "Dipole 20m",
            kind: .dipole,
            bands: "20m, 40m",
            heightMeters: 12,
            note: "Inverted-V",
            isActive: true
        ))

        let sampleContacts: [(String, String, Double, Double, RadioBand)] = [
            ("G3XYZ", "IO91", 51.5, -1.0, .m20),
            ("JA1ABC", "PM95", 35.7, 139.7, .m15),
            ("VK2TEST", "QF56", -33.9, 151.2, .m40),
            ("DL1HAM", "JO62", 50.1, 8.7, .m80)
        ]

        for (index, sample) in sampleContacts.enumerated() {
            let qsoDate = Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date()
            try await contacts.upsert(AirContact(
                id: UUID(),
                theirCallsign: sample.0,
                theirGrid: sample.1,
                theirLatitude: sample.2,
                theirLongitude: sample.3,
                band: sample.4,
                mode: .ssb,
                frequencyKHz: Int(sample.4.frequencyMHz * 1000),
                rstSent: "59",
                rstReceived: "59",
                qsoAt: qsoDate,
                antennaID: antennaID,
                note: "",
                stationID: homeID
            ))
        }
    }
}
