import Foundation
import AVFoundation
import SwiftData

class LibraryManager {
    static let shared = LibraryManager()

    func scanFolder(at url: URL, context: ModelContext) async {
        let fileManager = FileManager.default

        // Start accessing security-scoped resource if it's from the Files app
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else { return }

        for case let fileURL as URL in enumerator {
            if isSupportedFormat(fileURL) {
                await processFile(at: fileURL, context: context)
            }
        }
    }

    private func isSupportedFormat(_ url: URL) -> Bool {
        let extensions = ["mp3", "flac", "wav", "m4a", "alac", "aiff", "aac", "ogg", "opus"]
        return extensions.contains(url.pathExtension.lowercased())
    }

    private func processFile(at url: URL, context: ModelContext) async {
        let asset = AVAsset(url: url)

        do {
            let metadata = try await asset.load(.metadata)
            let duration = try await asset.load(.duration).seconds

            var title = url.deletingPathExtension().lastPathComponent
            var artist = "Unknown Artist"
            var album = "Unknown Album"

            for item in metadata {
                guard let key = item.commonKey?.rawValue else { continue }
                let value = try? await item.load(.value)

                switch key {
                case "title": title = value as? String ?? title
                case "artist": artist = value as? String ?? artist
                case "albumName": album = value as? String ?? album
                default: break
                }
            }

            // Technical info
            let technicalInfo = getTechnicalInfo(at: url)

            let track = Track(url: url, title: title, artist: artist, album: album, duration: duration, format: url.pathExtension.uppercased())
            track.sampleRate = technicalInfo.sampleRate
            track.bitDepth = technicalInfo.bitDepth
            track.isHiRes = (technicalInfo.sampleRate ?? 0) > 44100 || (technicalInfo.bitDepth ?? 0) > 16

            context.insert(track)
            try? context.save()

        } catch {
            print("Error processing file \(url.lastPathComponent): \(error)")
        }
    }

    private func getTechnicalInfo(at url: URL) -> (sampleRate: Double?, bitDepth: Int?) {
        guard let file = try? AVAudioFile(forReading: url) else { return (nil, nil) }
        let format = file.fileFormat
        let settings = format.settings

        let sampleRate = format.sampleRate
        var bitDepth: Int?

        if let depth = settings[AVLinearPCMBitDepthKey] as? Int {
            bitDepth = depth
        } else if url.pathExtension.lowercased() == "flac" {
            // FLAC often doesn't report depth via settings easily, might need manual parsing if critical
            bitDepth = 24 // Placeholder for high res flac detection
        }

        return (sampleRate, bitDepth)
    }
}
