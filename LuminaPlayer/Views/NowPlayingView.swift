import SwiftUI

struct NowPlayingView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var playback = PlaybackManager.shared
    @State private var showLyrics = false
    @State private var isDragging = false

    var body: some View {
        ZStack {
            // Background Gradient based on album art (concept)
            LinearGradient(colors: [.gray.opacity(0.4), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                // Header
                Capsule()
                    .fill(Color.secondary)
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                Spacer()

                // Album Art
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.3))
                        .shadow(radius: 20)

                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(80)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(width: 320, height: 320)
                .scaleEffect(playback.isPlaying ? 1.0 : 0.9)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: playback.isPlaying)

                Spacer()

                // Info
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(playback.currentTrack?.title ?? "Song Title")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(playback.currentTrack?.artist ?? "Artist Name")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    // Progress Bar
                    VStack {
                        Slider(value: $playback.currentTime, in: 0...playback.duration) { editing in
                            isDragging = editing
                        }
                        .accentColor(.white)

                        HStack {
                            Text(formatTime(playback.currentTime))
                            Spacer()
                            Text("-" + formatTime(playback.duration - playback.currentTime))
                        }
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal, 30)

                // Controls
                HStack(spacing: 50) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 35))
                    }

                    Button(action: { playback.togglePlayPause() }) {
                        Image(systemName: playback.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 60))
                    }

                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 35))
                    }
                }
                .foregroundColor(.white)

                Spacer()

                // Bottom bar
                HStack {
                    Image(systemName: "quote.bubble")
                    Spacer()
                    Image(systemName: "airplayaudio")
                    Spacer()
                    Image(systemName: "list.bullet")
                }
                .font(.title3)
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 60)
                .padding(.bottom, 20)
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
