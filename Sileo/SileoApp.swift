import SwiftUI

@main
struct SileoApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.scheme)
                .tint(.sileoTint)
        }
    }
}
