import Foundation
import AVFoundation
import MediaPlayer
import Combine

class PlaybackManager: NSObject, ObservableObject {
    static let shared = PlaybackManager()

    private var engine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var eqNode = AVAudioUnitEQ(numberOfBands: 10)

    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var displayLink: CADisplayLink?

    override init() {
        super.init()
        setupEngine()
        setupRemoteCommandCenter()
    }

    private func setupEngine() {
        engine.attach(playerNode)
        engine.attach(eqNode)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(playerNode, to: eqNode, format: format)
        engine.connect(eqNode, to: engine.mainMixerNode, format: format)

        try? engine.start()

        setupDisplayLink()
    }

    func play(_ track: Track) {
        stop()

        guard let file = try? AVAudioFile(forReading: track.url) else { return }

        self.currentTrack = track
        self.duration = track.duration

        playerNode.scheduleFile(file, at: nil) { [weak self] in
            // Handle completion/looping
        }

        if !engine.isRunning {
            try? engine.start()
        }

        playerNode.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        if isPlaying {
            playerNode.pause()
            isPlaying = false
        } else {
            playerNode.play()
            isPlaying = true
        }
        updateNowPlayingInfo()
    }

    func stop() {
        playerNode.stop()
        isPlaying = false
        currentTime = 0
    }

    func seek(to time: TimeInterval) {
        // Implementation for seeking in AVAudioEngine is complex
        // Usually involves stopping, recalculating frames, and rescheduling
    }

    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateProgress() {
        guard isPlaying, let lastRenderTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime) else { return }

        currentTime = Double(playerTime.sampleTime) / playerTime.sampleRate
    }

    private func setupRemoteCommandCenter() {
        let rcc = MPRemoteCommandCenter.shared()

        rcc.playCommand.isEnabled = true
        rcc.playCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        rcc.pauseCommand.isEnabled = true
        rcc.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        rcc.nextTrackCommand.isEnabled = true
        rcc.previousTrackCommand.isEnabled = true
    }

    private func updateNowPlayingInfo() {
        guard let track = currentTrack else { return }

        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = track.title
        info[MPMediaItemPropertyArtist] = track.artist
        info[MPMediaItemPropertyPlaybackDuration] = track.duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        // Async load artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // EQ Profiles
    func applyEQ(gains: [Float]) {
        for (index, gain) in gains.enumerated() {
            if index < eqNode.bands.count {
                eqNode.bands[index].gain = gain
            }
        }
    }
}
