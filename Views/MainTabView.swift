import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showNowPlaying = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                LibraryView()
                    .tabItem { Label("Library", systemImage: "music.note.list") }
                    .tag(1)

                PlaylistView()
                    .tabItem { Label("Playlists", systemImage: "music.note.house.fill") }
                    .tag(2)

                SearchView()
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(3)

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
                    .tag(4)
            }
            .accentColor(.pink)

            // Mini Player
            if PlaybackManager.shared.currentTrack != nil {
                MiniPlayerView()
                    .onTapGesture {
                        showNowPlaying = true
                    }
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, 50) // Adjust for TabBar height
            }
        }
        .fullScreenCover(isPresented: $showNowPlaying) {
            NowPlayingView()
        }
    }
}

struct MiniPlayerView: View {
    @ObservedObject var playback = PlaybackManager.shared

    var body: some View {
        HStack {
            Image(systemName: "music.note") // Placeholder for album art
                .resizable()
                .frame(width: 45, height: 45)
                .cornerRadius(5)
                .padding(.leading, 10)

            VStack(alignment: .leading) {
                Text(playback.currentTrack?.title ?? "Not Playing")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(playback.currentTrack?.artist ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { playback.togglePlayPause() }) {
                Image(systemName: playback.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .padding(.trailing, 20)
        }
        .frame(height: 65)
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(12)
        .padding(.horizontal, 10)
        .shadow(radius: 5)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
