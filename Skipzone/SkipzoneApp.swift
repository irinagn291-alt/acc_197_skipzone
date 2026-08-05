import SwiftUI
import UIKit

@main
struct SkipzoneApp: App {
    @StateObject private var environment = AppEnvironment.live()

    init() {
        SkipFontRegistry.register()
        let paper = UIColor(red: 0xF2 / 255, green: 0xEE / 255, blue: 0xE3 / 255, alpha: 1)
        UIWindow.appearance().backgroundColor = paper
        UIScrollView.appearance().backgroundColor = .clear
        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment)
                .skipScreenBackground(.light)
                .skipTheme()
                .preferredColorScheme(.light)
        }
    }
}
