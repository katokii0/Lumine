import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Listen Now")
                        .font(.largeTitle)
                        .bold()
                        .padding()

                    SectionView(title: "Recently Added")
                    SectionView(title: "Most Played")
                    SectionView(title: "Hi-Res Favorites")
                }
            }
        }
    }
}

struct SectionView: View {
    let title: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 160, height: 160)
                            Text("Album Title")
                                .font(.headline)
                            Text("Artist")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct PlaylistView: View {
    var body: some View {
        NavigationView {
            List {
                Button(action: {}) {
                    Label("New Playlist...", systemImage: "plus")
                }
                Text("My Awesome Mix")
                Text("Classical Focus")
            }
            .navigationTitle("Playlists")
        }
    }
}

struct SearchView: View {
    @State private var searchText = ""
    var body: some View {
        NavigationView {
            Text("Search functionality")
                .searchable(text: $searchText)
                .navigationTitle("Search")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section("Playback") {
                    NavigationLink("Equalizer") {
                        Text("10-band EQ settings here")
                    }
                    Toggle("Crossfade", isOn: .constant(true))
                    Toggle("Gapless Playback", isOn: .constant(true))
                    Toggle("Normalise Volume", isOn: .constant(false))
                }

                Section("Library") {
                    Text("Manage Folders")
                    Text("Re-scan Library")
                    Text("Clear Cache")
                }

                Section("Appearance") {
                    Text("Theme (Auto/Light/Dark)")
                }

                Section("About") {
                    Text("Lumina Player v1.0")
                    Text("Hi-Res Audio Engine Active")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
