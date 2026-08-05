import Foundation

enum SkipFormatters {
    static let qsoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static let distance: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func distanceLabel(km: Double) -> String {
        let value = distance.string(from: NSNumber(value: km)) ?? "\(Int(km))"
        return "\(value) km"
    }

    static func bearingLabel(degrees: Double) -> String {
        String(format: "%.0f°", degrees)
    }
}
