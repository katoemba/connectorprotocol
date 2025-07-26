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
    case Unknown, Local, Spotify, TuneIn, Podcast, Shoutcast, UPnP, Tidal, Qobuz, Radio
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
    
    func songsOnAlbum(_ album: Album) async throws -> [Song]

    func songsInPlaylist(_ playlist: Playlist) async throws -> [Song]
    
    func recentAlbums() async throws -> [Album]

    func recentAlbums(numberOfAlbums: Int) async throws -> [Album]
    
    func artists(type: ArtistType) async throws -> [Artist]

    func artists(genre: Genre) async throws -> [Artist]

    func albums() async throws -> [Album]
    
    func albums(genre: Genre?) async throws -> [Album]
    
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
    
    /// Select a number of random songs from the collection
    /// - Parameter count: the number of songs to return
    /// - Returns: an array of songs
    func randomSongs(_ count: Int) async throws -> [Song]
    
    /// Select a random album from the collection
    /// - Returns: the selected album
    func randomAlbums(_ count: Int) async throws -> [Album]
    
    func coverData(_ album: Album) async throws -> Data
    
    func coverData(_ song: Song) async throws -> Data
    
    func genres() async throws -> [Genre]
}
