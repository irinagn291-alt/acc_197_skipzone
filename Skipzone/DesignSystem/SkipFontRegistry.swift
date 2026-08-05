import CoreText
import SwiftUI
import UIKit

enum SkipFontRegistry {
    static let callsignFamily = "CourierPrime-Regular"

    static func register() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else { return }
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func callsignFont(_ style: Font.TextStyle = .body) -> Font {
        if UIFont(name: callsignFamily, size: 17) != nil {
            return .custom(callsignFamily, size: style.pointSize, relativeTo: style)
        }
        return SkipTokens.callsignFont(style)
    }
}

private extension Font.TextStyle {
    var pointSize: CGFloat {
        switch self {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline: 17
        case .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        @unknown default: 17
        }
    }
}
