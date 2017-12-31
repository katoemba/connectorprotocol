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
    
    /// The song's release date. This is usually a 4-digit year.
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
    
    /// The name of the track.
    public var name = ""
    
    /// The (release)date of the track. This is a string value and often contains just the year.
    public var date = ""
    
    /// The performer of the track.
    public var performer = ""
    
    /// A human-readable comment about this song. The exact meaning of this tag is not well-defined.
    public var comment = ""
    
    /// The decimal disc number in a multi-disc album.
    public var disc = ""

    /// The Musicbrainz Artist Id for the artist of the track.
    public var musicbrainzArtistId = ""
    
    /// The Musicbrainz Album Id for the album of the track.
    public var musicbrainzAlbumId = ""
    
    /// The Musicbrainz Artist Id for the album-artist of the track.
    public var musicbrainzAlbumArtistId = ""
    
    /// The Musicbrainz Track Id of the track.
    public var musicbrainzTrackId = ""
    
    /// The Musicbrainz Release Id of the track.
    public var musicbrainzReleaseId = ""
    
    public var originalDate = ""
    
    /// Alternative value to sort by when sorting by artist (like Rolling Stones, The).
    public var sortArtist = ""
    
    /// Alternative value to sort by when sorting by album-artist (like Rolling Stones, The).
    public var sortAlbumArtist = ""
    
    /// Alternative value to sort by when sorting by album.
    public var sortAlbum = ""
    
    /// URI through which cover art can be fetched.
    public var coverURI = ""
    
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