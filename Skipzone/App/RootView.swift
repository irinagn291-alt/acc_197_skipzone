import SwiftUI

struct RootView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        SkipSplashGate()
            .task { await environment.bootstrap() }
    }
}
