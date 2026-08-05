import Foundation

enum BandHeatmapAggregator {
    static func aggregate(contacts: [AirContact], calendar: Calendar = .current) -> [BandHourCell] {
        var counts: [String: Int] = [:]
        for contact in contacts {
            let hour = calendar.component(.hour, from: contact.qsoAt)
            let key = "\(contact.band.rawValue)-\(hour)"
            counts[key, default: 0] += 1
        }

        var cells: [BandHourCell] = []
        for band in RadioBand.allCases {
            for hour in 0..<24 {
                let key = "\(band.rawValue)-\(hour)"
                cells.append(BandHourCell(band: band, hour: hour, count: counts[key, default: 0]))
            }
        }
        return cells
    }

    static func maxCount(in cells: [BandHourCell]) -> Int {
        cells.map(\.count).max() ?? 1
    }

    static func intensity(for cell: BandHourCell, maxCount: Int) -> Double {
        guard maxCount > 0 else { return 0 }
        return Double(cell.count) / Double(maxCount)
    }
}
