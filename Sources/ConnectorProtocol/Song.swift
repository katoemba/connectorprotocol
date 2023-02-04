//
//  Song.swift
//  ConnectorProtocol
//
// The MIT License (MIT)
//
// Copyright (c) 2018 Katoemba Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// A struct defining a generic Song object.
public struct Song: Codable {
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
    
    /// A service specific id for an album
    public var albumId: String? = nil
    
    /// The name of the artist(s) that perform the song.
    public var artist = ""

    /// A service specific id for an artist
    public var aristId: String? = nil

    /// The name of the artist that released the album of which this song is part.
    public var albumartist = ""
    
    /// The name of the composer of the song.
    public var composer = ""
    
    /// The song's release date. This is usually a 4-digit year.
    public var year = 0
    
    /// The name of the genre to which the song belongs.
    public var genre = [] as [String]
    
    /// The duration of the song in seconds.
    public var length = 0
    
    /// The position of the track within the playqueue
    public var position = 0
    
    /// A unique id of a track in the playqueue
    public var playqueueId: String? = nil
    
    /// The name of the track.
    public var name = ""
    
    /// The (release)date of the track. This is a string value and often contains just the year.
    public var date = ""
    
    /// The performer of the track.
    public var performer = ""
    
    /// A human-readable comment about this song. The exact meaning of this tag is not well-defined.
    public var comment = ""
    
    /// The track number of a song.
    public var track = 0
    
    /// The decimal disc number in a multi-disc album.
    public var disc = 0

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
    public var coverURI = CoverURI.fullPathURI("")
    
    /// Date the album was last modified.
    public var lastModified = Date(timeIntervalSince1970: 0)

    /// The quality of the song
    public var quality = QualityStatus()
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                location: String,
                title: String,
                album: String,
                albumId: String? = nil,
                artist: String,
                artistId: String? = nil,
                albumartist: String,
                composer: String,
                year: Int,
                genre: [String],
                length: Int,
                quality: QualityStatus,
                position: Int = 0,
                playqueueId: String? = nil,
                track: Int = 0,
                disc: Int = 1,
                coverURI: CoverURI = CoverURI.fullPathURI(""),
                sortArtist: String = "",
                sortAlbumArtist: String = "",
                sortAlbum: String = "",
                lastModified: Date = Date(timeIntervalSince1970: 0)) {
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
        self.quality = quality
        self.position = position
        self.playqueueId = playqueueId
        self.track = track
        self.disc = disc
        self.coverURI = coverURI
        self.sortArtist = sortArtist
        self.sortAlbumArtist = sortAlbumArtist
        self.sortAlbum = sortAlbum
        self.lastModified = lastModified
    }
}

extension Song: Equatable {}
public func ==(lhs: Song, rhs: Song) -> Bool {
    if let lplayqueueId = lhs.playqueueId, let rplayqueueId = rhs.playqueueId {
        return lplayqueueId == rplayqueueId
    }
    
    return lhs.id == rhs.id && lhs.source == rhs.source &&
        lhs.title == rhs.title && lhs.album == rhs.album && lhs.artist == rhs.artist
}

extension Song: Hashable {
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
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
            "    quality = \(quality)\n" +
            "    track = \(track)\n" +
            "    disc = \(disc)\n" +
            "    position = \(position)"
    }
}

public extension Song {
    typealias SongToStringConvertor = (Song) -> (String)
    
    var extendedAlbumArtist: String {
        albumartist != "" ? albumartist : artist
    }
    
    var extendedSortArtist: String {
        sortArtist != "" ? sortArtist : artist
    }

    var extendSortAlbumArtist: String {
        if sortAlbumArtist != "" {
            return sortAlbumArtist
        }
        else if albumartist != "" {
            return albumartist
        }
        else if sortArtist != "" {
            return sortArtist
        }
        else {
            return artist
        }
    }
    
    var extendedSortAlbum: String {
        sortAlbum != "" ? sortAlbum : album
    }
    
    func createAlbum(idCreator: SongToStringConvertor? = nil,
                     locationCreator: SongToStringConvertor? = nil) -> Album {
        let id = idCreator?(self) ?? "\(source.rawValue)::\(extendedAlbumArtist)::\(album)"
        let location = locationCreator?(self) ?? ""
        
        return Album(id: id,
                     source: source,
                     location: location,
                     title: album,
                     artist: extendedAlbumArtist,
                     year: year,
                     genre: genre,
                     sortTitle: extendedSortAlbum,
                     sortArtist: extendSortAlbumArtist,
                     lastModified: lastModified,
                     coverURI: coverURI,
                     quality: quality)
    }
    
    func createArtist(type: ArtistType,
                      idCreator: SongToStringConvertor? = nil) -> Artist? {
        
        switch type {
        case .artist:
            let id = idCreator?(self) ?? "\(source.rawValue)::\(artist)"
            return Artist(id: id, type: .artist, source: source, name: self.artist, sortName: extendedSortArtist)
        case .albumArtist:
            let id = idCreator?(self) ?? "\(source.rawValue)::\(extendedAlbumArtist)"
            return Artist(id: id, type: .albumArtist, source: source, name: extendedAlbumArtist, sortName: extendSortAlbumArtist)
        case .composer:
            if composer != "" {
                let id = idCreator?(self) ?? "\(source.rawValue)::\(composer)"
                return Artist(id: id, type: .composer, source: source, name: composer, sortName: composer)
            }
        case .performer:
            if performer != "" {
                let id = idCreator?(self) ?? "\(source.rawValue)::\(performer)"
                return Artist(id: id, type: .performer, source: source, name: performer, sortName: performer)
            }
        }
        
        return nil
    }
}
