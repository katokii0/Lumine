import Foundation
import SwiftData
import AVFoundation

@Model
final class Track {
    @Attribute(.unique) var urlString: String
    var title: String
    var artist: String
    var album: String
    var genre: String
    var year: Int?
    var trackNumber: Int?
    var duration: Double
    var dateAdded: Date
    var playCount: Int
    var isFavorite: Bool

    // Technical details
    var format: String
    var bitrate: Int?
    var sampleRate: Double?
    var bitDepth: Int?
    var isHiRes: Bool

    @Relationship(deleteRule: .nullify, inverse: \Album.tracks)
    var albumRef: Album?

    @Relationship(deleteRule: .nullify, inverse: \Artist.tracks)
    var artistRef: Artist?

    init(url: URL, title: String, artist: String, album: String, genre: String = "Unknown", duration: Double = 0, format: String = "") {
        self.urlString = url.path
        self.title = title
        self.artist = artist
        self.album = album
        self.genre = genre
        self.duration = duration
        self.dateAdded = Date()
        self.playCount = 0
        self.isFavorite = false
        self.format = format
        self.isHiRes = false
    }

    var url: URL {
        URL(fileURLWithPath: urlString)
    }
}

@Model
final class Album {
    @Attribute(.unique) var name: String
    var artistName: String
    var year: Int?

    @Relationship(deleteRule: .cascade)
    var tracks: [Track] = []

    init(name: String, artistName: String, year: Int? = nil) {
        self.name = name
        self.artistName = artistName
        self.year = year
    }
}

@Model
final class Artist {
    @Attribute(.unique) var name: String

    @Relationship(deleteRule: .cascade)
    var tracks: [Track] = []

    init(name: String) {
        self.name = name
    }
}

@Model
final class Playlist {
    var name: String
    var creationDate: Date
    var isSmart: Bool

    @Relationship(deleteRule: .nullify)
    var tracks: [Track] = []

    init(name: String, isSmart: Bool = false) {
        self.name = name
        self.creationDate = Date()
        self.isSmart = isSmart
    }
}
