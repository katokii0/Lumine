import SwiftUI
import SwiftData

@main
struct LuminaPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Track.self, Album.self, Artist.self, Playlist.self])
    }
}
