import SwiftUI

@main
struct RecallGardenApp: App {
    @StateObject private var library = Library()

    var body: some Scene {
        WindowGroup {
            HomeView().environmentObject(library).tint(Theme.ink)
        }
    }
}
