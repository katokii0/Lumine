import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \Track.title) var tracks: [Track]
    @Environment(\.modelContext) private var modelContext
    @State private var showingImporter = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: Text("Albums")) {
                        Label("Albums", systemImage: "square.stack")
                    }
                    NavigationLink(destination: Text("Artists")) {
                        Label("Artists", systemImage: "music.mic")
                    }
                    NavigationLink(destination: Text("Downloaded")) {
                        Label("Downloaded", systemImage: "arrow.down.circle")
                    }
                }

                Section("Recent Activity") {
                    ForEach(tracks.prefix(5)) { track in
                        TrackRow(track: track)
                    }
                }

                Section("Library") {
                    ForEach(tracks) { track in
                        TrackRow(track: track)
                            .onTapGesture {
                                PlaybackManager.shared.play(track)
                            }
                    }
                }
            }
            .navigationTitle("Library")
            .toolbar {
                Button(action: { showingImporter = true }) {
                    Image(systemName: "plus.circle")
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        Task {
                            await LibraryManager.shared.scanFolder(at: url, context: modelContext)
                        }
                    }
                case .failure(let error):
                    print("Import failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct TrackRow: View {
    let track: Track

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "music.note")
                        .foregroundColor(.secondary)
                )

            VStack(alignment: .leading) {
                Text(track.title)
                    .font(.body)
                Text(track.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if track.isHiRes {
                Text("HI-RES")
                    .font(.system(size: 8, weight: .bold))
                    .padding(4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(4)
            }

            Text(track.format)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}
