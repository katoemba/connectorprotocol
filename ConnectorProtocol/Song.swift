//
//  Song.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

/// A struct defining a generic Song object.
public struct Song {
    /// A unique id for the song. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this song (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Unknown
    
    /// The location of the song. Usage depends on library implementation.
    public var location = ""
    
    /// The title of the song.
    public var title = ""
    
    /// The title of the album on which the song appears.
    public var album = ""
    
    /// The name of the artist(s) that perform the song.
    public var artist = ""
    
    /// The name of the artist that released the album of which this song is part.
    public var albumartist = ""
    
    /// The name of the composer of the song.
    public var composer = ""
    
    /// The year the song was released.
    public var year = 0
    
    /// The name of the genre to which the song belongs.
    public var genre = ""
    
    /// The duration of the song in seconds.
    public var length = 0
    
    /// A string describing the bitrate of the song.
    public var bitrate = ""
    
    /// A string describing the encoding of the song.
    public var encoding = ""
    
    /// The position of the track within a playlist, album or playqueue
    public var position = 0
    
    public var name = ""
    
    public var date = ""
    
    public var performer = ""
    
    public var comment = ""
    
    public var disc = ""
    
    public var musicbrainzArtistId = ""
    
    public var musicbrainzAlbumId = ""
    
    public var musicbrainzAlbumArtistId = ""
    
    public var musicbrainzTrackId = ""
    
    public var musicbrainzReleaseId = ""
    
    public var originalDate = ""
    
    public var sortArtist = ""
    
    public var sortAlbumArtist = ""
    
    public var sortAlbum = ""
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                location: String,
                title: String,
                album: String,
                artist: String,
                albumartist: String,
                composer: String,
                year: Int,
                genre: String,
                length: Int,
                bitrate: String,
                encoding: String,
                position: Int = 0) {
        self.id = id
        self.source = source
        self.location = location
        self.title = title
        self.album = album
        self.artist = artist
        self.albumartist = albumartist
        self.composer = composer
        self.year = year
        self.genre = genre
        self.length = length
        self.bitrate = bitrate
        self.encoding = encoding
        self.position = position
    }
}

extension Song: Equatable {}
public func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source
}

extension Song: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

extension Song: CustomStringConvertible {
    public var description: String {
        return "> Song\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    title = \(title)\n"
    }
}

extension Song: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Song\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    title = \(title)\n" +
            "    location = \(location)\n" +
            "    album = \(album)\n" +
            "    artist = \(artist)\n" +
            "    albumartist = \(albumartist)\n" +
            "    composer = \(composer)\n" +
            "    year = \(year)\n" +
            "    genre = \(genre)\n" +
            "    length = \(length)\n" +
            "    bitrate = \(bitrate)\n" +
            "    encoding = \(encoding)\n"
    }
}
