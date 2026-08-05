import SwiftUI

enum SkipImage: String, CaseIterable {
    case brandMark = "brand-mark"
    case onboardingRadio = "onboarding-radio"
    case onboardingGrid = "onboarding-grid"
    case onboardingQsl = "onboarding-qsl"
    case onboardingLog = "onboarding-log"
    case emptyContacts = "empty-contacts"
    case emptyAntennas = "empty-antennas"
    case emptyPropNotes = "empty-prop-notes"
    case mapBanner = "map-banner"
    case statsBanner = "stats-banner"
    case backupEmpty = "backup-empty"

    var image: Image { Image(rawValue) }
}
