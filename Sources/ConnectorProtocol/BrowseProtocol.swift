//
//  BrowseProtocol.swift
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

public enum SourceType: String, Codable, Sendable {
    case Unknown, Local, Spotify, TuneIn, Podcast, Shoutcast, UPnP, Tidal, Qobuz, Radio, AppleMusic
}

public enum LoadStatus {
    case initial                // Only initial key information (like an id or artist/album combination) is present.
    case completionInProgress   // A request to complete all data in progress
    case complete               // All data is available
}

public enum SortType: String {
    case artist
    case year
    case yearReverse
    case title
}

public enum BrowseFilter {
    case genre(Genre)
    case artist(Artist)
    case album(Album)
    case related(Album)
    case playlist(Playlist)
    case recent(Int)
    case folder(Folder)
    case type(ArtistType)
    case random(Int)
    case streamingRecent(genre: String?)
    case streamingFeatured(genre: String?)
    case streamingPopular(genre: String?)
    case streamingFavorite
    case similarArtists(Artist)
    case tip
}

public enum SearchItem {
    case genre(name: String)
    case artist(name: String)
    case song(title: String, artist: String?)
    case album(title: String, artist: String?)
    case artistAlbum(artist: String, sort: SortType)
    case playlist(name: String)
    case decade(decade: Int)
}

public enum FoundItem: Hashable, Equatable {
    case genre(Genre)
    case artist(Artist)
    case song(Song)
    case album(Album)
    case playlist(Playlist)
}

public enum LoadProgress {
    case notStarted
    case loading
    case dataAvailable
    case noDataFound
    case allDataLoaded
}

public enum FolderContent {
    case folder(Folder)
    case song(Song)
    case playlist(Playlist)
}


public struct Result<T> {
    public init(total: UInt32, offset: UInt32, limit: UInt32, items: [T]) {
        self.total = total
        self.offset = offset
        self.limit = limit
        self.items = items
    }
    
    public let total: UInt32
    public let offset: UInt32
    public let limit: UInt32
    public let items: [T]
}

/// A protocol to provide a generic interface to a music library.
public protocol BrowseProtocol: Sendable {
    /// Name of browser
    var name: String { get }

    /// Description of the current status of the cache. Return nil if a cache is not supported.
    var cacheStatus: String? { get }

    func songsByArtist(_ artist: Artist) async throws -> [Song]
 
    func albumsByArtist(_ artist: Artist, sort: SortType) async throws -> [Album]

    func playlists() async throws -> [Playlist]
    
    func songsInPlaylist(_ playlist: Playlist) async throws -> [Song]
    
    func addSong(_ song: Song, playlist: Playlist) async throws
    
    func removeSongAtIndex(_ index: Int, fromPlaylist playlist: Playlist) async throws
    
    func moveSongAtIndex(_ index: Int, to: Int, playlist: Playlist) async throws
    
    func delete(_ playlist: Playlist) async throws
    
    func rename(_ playlist: Playlist, newName: String) async throws
    
    func songsOnAlbum(_ album: Album) async throws -> [Song]

    func recentAlbums() async throws -> [Album]

    func recentAlbums(numberOfAlbums: Int) async throws -> [Album]
    
    func recentSongs() async throws -> [Song]
    
    func artists(type: ArtistType) async throws -> [Artist]

    func artists(genre: Genre) async throws -> [Artist]

    func albums() async throws -> [Album]
    
    func albums(genre: Genre?) async throws -> [Album]
    
    func songs(genre: Genre) async throws -> [Song]
    
    func albumsByDecade(_ decade: Int) async throws -> [Album]
    
    func songsByDecade(_ decade: Int) async throws -> [Song]
    
    func existingArtists(artists: [Artist]) async throws -> [Artist]

    func similarArtists(artist: Artist) async throws -> [Artist]

    /// Complete data for a song
    /// - Parameter song: a song for which data must be completed
    /// - Returns: an observable song
    func complete(_ song: Song) async throws -> Song

    func completeAlbums(_ albums: [Album]) async throws -> [Album]
    
    func complete(_ album: Album) async throws -> Album

    func complete(_ artist: Artist) async throws -> Artist

    /// Search for the existence a certain item
    /// - Parameter searchItem: what to search for
    /// - Returns: an observable array of results
    func search(searchItem: SearchItem) async throws -> [FoundItem]
    
    func search(_ search: String, limit: Int, filter: [SourceType]) async throws -> SearchResult
    
    /// Select a number of random songs from the collection
    /// - Parameter count: the number of songs to return
    /// - Returns: an array of songs
    func randomSongs(_ count: Int) async throws -> [Song]
    
    /// Select a random album from the collection
    /// - Returns: the selected album
    func randomAlbums(_ count: Int) async throws -> [Album]
    
    func coverData(_ album: Album) async throws -> Data
    
    func coverData(_ album: Album, cacheValidator: @escaping (String) -> Data?) async throws -> Data

    func coverData(_ song: Song) async throws -> Data

    func coverData(_ song: Song, cacheValidator: @escaping (String) -> Data?) async throws -> Data

    func genres() async throws -> [Genre]
    
    func folderContents(_ folder: Folder) async throws -> [FolderContent]
    
    /// The album collections that this browser can present, like new releases, best sellers or press awards.
    /// - Returns: an array of streaming collections, empty if the browser doesn't support album collections
    func albumCollections() async throws -> [StreamingCollection]

    /// The playlist collections that this browser can present, like editor picks or last created.
    /// - Returns: an array of streaming collections, empty if the browser doesn't support playlist collections
    func playlistCollections() async throws -> [StreamingCollection]

    /// The song collections that this browser can present, like most streamed or favorites.
    /// - Returns: an array of streaming collections, empty if the browser doesn't support song collections
    func songCollections() async throws -> [StreamingCollection]

    /// The radio station collections that this browser can present, like local or popular stations.
    /// - Returns: an array of streaming collections, empty if the browser doesn't support radio station collections
    func radioStationCollections() async throws -> [StreamingCollection]

    /// Get the albums in a collection, optionally limited to a genre.
    /// - Parameters:
    ///   - genre: the genre to filter on, nil to get albums for all genres
    ///   - collection: the collection to get albums from, nil to use the default collection of the browser
    ///   - offset: the index of the first album to return
    ///   - limit: the maximum number of albums to return
    /// - Returns: a result containing the requested albums
    func albums(genre: Genre?, collection: StreamingCollection, offset: UInt32, limit: UInt32) async throws -> Result<Album>

    /// Get the playlists in a collection, optionally limited to a genre.
    /// - Parameters:
    ///   - genre: the genre to filter on, nil to get playlists for all genres
    ///   - collection: the collection to get playlists from, nil to use the default collection of the browser
    ///   - offset: the index of the first playlist to return
    ///   - limit: the maximum number of playlists to return
    /// - Returns: a result containing the requested playlists
    func playlists(genre: Genre?, collection: StreamingCollection, offset: UInt32, limit: UInt32) async throws -> Result<Playlist>

    /// Get the songs in a collection, optionally limited to a genre.
    /// - Parameters:
    ///   - genre: the genre to filter on, nil to get songs for all genres
    ///   - collection: the collection to get songs from, nil to use the default collection of the browser
    ///   - offset: the index of the first song to return
    ///   - limit: the maximum number of songs to return
    /// - Returns: a result containing the requested songs
    func songs(genre: Genre?, collection: StreamingCollection, offset: UInt32, limit: UInt32) async throws -> Result<Song>
}

public extension BrowseProtocol {
    func albumCollections() async throws -> [StreamingCollection] {
        []
    }

    func playlistCollections() async throws -> [StreamingCollection] {
        []
    }

    func songCollections() async throws -> [StreamingCollection] {
        []
    }

    func radioStationCollections() async throws -> [StreamingCollection] {
        []
    }

    func albums(genre: Genre?, collection: StreamingCollection, offset: UInt32, limit: UInt32) async throws -> Result<Album> {
        throw ControlError.notImplemented(function: "albums(genre:collection:offset:limit:)")
    }

    func playlists(genre: Genre?, collection: StreamingCollection, offset: UInt32, limit: UInt32) async throws -> Result<Playlist> {
        throw ControlError.notImplemented(function: "playlists(genre:collection:offset:limit:)")
    }

    func songs(genre: Genre?, collection: StreamingCollection, offset: UInt32, limit: UInt32) async throws -> Result<Song> {
        throw ControlError.notImplemented(function: "songs(genre:collection:offset:limit:)")
    }
}
