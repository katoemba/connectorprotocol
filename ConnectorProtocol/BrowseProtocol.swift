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
import RxSwift

public enum SourceType {
    case Unknown, Local, Spotify, TuneIn, Podcast
}

public enum SortType: String {
    case artist
    case year
    case yearReverse
    case title
}

public enum BrowseFilter {
    case genre(String)
    case artist(Artist)
    case album(Album)
    case playlist(Playlist)
    case recent(Int)
    case folder(Folder)
    case type(ArtistType)
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
}

public protocol AlbumBrowseViewModel {
    var loadProgressObservable: Observable<LoadProgress> { get }
    var albumsObservable: Observable<[Album]> { get }
    var filters: [BrowseFilter] { get }
    var sort: SortType { get }
    var availableSortOptions: [SortType] { get }
    
    func load(sort: SortType)
    func load(filters: [BrowseFilter])
    func extend()
    func extend(to: Int)
}

public protocol ArtistBrowseViewModel {
    var loadProgressObservable: Observable<LoadProgress> { get }
    var artistsObservable: Observable<[Artist]> { get }
    var filters: [BrowseFilter] { get }
    var artistType: ArtistType { get }
    
    func load()
    func load(filters: [BrowseFilter])
    func extend()
}

public protocol PlaylistBrowseViewModel {
    var loadProgressObservable: Observable<LoadProgress> { get }
    var playlistsObservable: Observable<[Playlist]> { get }
    
    func load()
    func extend()
    
    func renamePlaylist(_ playlist: Playlist, to: String) -> Playlist
    func deletePlaylist(_ playlist: Playlist)
}

public protocol SongBrowseViewModel {
    var loadProgressObservable: Observable<LoadProgress> { get }
    var songsObservable: Observable<[Song]> { get }
    var filters: [BrowseFilter] { get }

    func load()
    func extend()
}

public protocol GenreBrowseViewModel {
    var loadProgressObservable: Observable<LoadProgress> { get }
    var genresObservable: Observable<[String]> { get }
    
    func load()
    func extend()
}

public protocol FolderBrowseViewModel {
    var loadProgressObservable: Observable<LoadProgress> { get }
    var folderContentsObservable: Observable<[FolderContent]> { get }
    var parentFolder: Folder? { get }

    func load()
    func extend()
}

/// A protocol to provide a generic interface to a music library.
public protocol BrowseProtocol {
    /// Get the songs performed by an artist.
    ///
    /// - Parameter artist: An Artist object.
    /// - Returns: An observable array of fully populated Song objects.
    func songsByArtist(_ artist: Artist) -> Observable<[Song]>
 
    /// Get the albums released by an artist (based on albumartist).
    ///
    /// - Parameters:
    ///   - artist: An Artist object.
    ///   - sort: How to sort the albums.
    /// - Returns: An observable array of fully populated Album objects.
    func albumsByArtist(_ artist: Artist, sort: SortType) -> Observable<[Album]>

    /// Get the songs on an album
    ///
    /// - Parameter album: An Album object.
    /// - Returns: An array of fully populated Song objects.
    func songsOnAlbum(_ album: Album) -> Observable<[Song]>

    /// Get the songs in a playlist
    ///
    /// - Parameter playlist: A Playlist object.
    /// - Returns: An array of fully populated Song objects.
    func songsInPlaylist(_ playlist: Playlist) -> Observable<[Song]>
    
    /// Search across artists, songs and albums.
    ///
    /// - Parameters:
    ///   - search: The text to search on.
    ///   - limit: The maximum number of items to return
    ///   - filter: The sources to filter on
    /// - Returns: An observable search object containing search results of different types.
    func search(_ search: String, limit: Int, filter: [SourceType]) -> Observable<SearchResult>
    
    /// Return a view model for a list of albums, which can return albums in batches.
    ///
    /// - Returns: an AlbumBrowseViewModel instance
    func albumBrowseViewModel() -> AlbumBrowseViewModel

    /// Return a view model for a list of albums filtered by artist, which can return albums in batches.
    ///
    /// - Parameter artist: artist to filter on
    /// - Returns: an AlbumBrowseViewModel instance
    func albumBrowseViewModel(_ artist: Artist) -> AlbumBrowseViewModel

    /// Return a view model for a list of albums filtered by genre, which can return albums in batches.
    ///
    /// - Parameter genre: genre to filter on
    /// - Returns: an AlbumBrowseViewModel instance
    func albumBrowseViewModel(_ genre: String) -> AlbumBrowseViewModel

    /// Return a view model for a preloaded list of albums.
    ///
    /// - Parameter albums: list of albums to show
    /// - Returns: an AlbumBrowseViewModel instance
    func albumBrowseViewModel(_ albums: [Album]) -> AlbumBrowseViewModel

    /// Return a view model for a list of artists, which can return artists in batches.
    ///
    /// - Returns: an ArtistBrowseViewModel instance
    func artistBrowseViewModel(type: ArtistType) -> ArtistBrowseViewModel
    
    /// Return a view model for a list of artists filtered by genre, which can return artist in batches.
    ///
    /// - Parameter genre: genre to filter on
    /// - Returns: an ArtistBrowseViewModel instance
    func artistBrowseViewModel(_ genre: String, type: ArtistType) -> ArtistBrowseViewModel
    
    /// Return a view model for a preloaded list of artists.
    ///
    /// - Parameter artists: list of artists to show
    /// - Returns: an ArtistBrowseViewModel instance
    func artistBrowseViewModel(_ artists: [Artist]) -> ArtistBrowseViewModel

    /// Return a view model for a list of playlists, which can return playlists in batches.
    ///
    /// - Returns: an PlaylistBrowseViewModel instance
    func playlistBrowseViewModel() -> PlaylistBrowseViewModel
    
    /// Return a view model for a preloaded list of playlists.
    ///
    /// - Parameter playlists: list of playlists to show
    /// - Returns: an PlaylistBrowseViewModel instance
    func playlistBrowseViewModel(_ playlists: [Playlist]) -> PlaylistBrowseViewModel
    
    /// Return a view model for a preloaded list of songs.
    ///
    /// - Parameter songs: list of songs to show
    /// - Returns: a SongBrowseViewModel instance
    func songBrowseViewModel(_ songs: [Song]) -> SongBrowseViewModel
    
    /// Return a view model for a list of songs in an album, which can return songs in batches.
    ///
    /// - Parameter album: album to filter on
    /// - Returns: a SongBrowseViewModel instance
    func songBrowseViewModel(_ album: Album) -> SongBrowseViewModel

    /// Return a view model for a list of songs in a playlist, which can return songs in batches.
    ///
    /// - Parameter playlist: playlist to filter on
    /// - Returns: a SongBrowseViewModel instance
    func songBrowseViewModel(_ playlist: Playlist) -> SongBrowseViewModel

    /// Return a view model for a list of genres, which can return genres in batches.
    ///
    /// - Returns: an GenreBrowseViewModel instance
    func genreBrowseViewModel() -> GenreBrowseViewModel
    
    /// Return a view model for a list of items in the root folder. Contents might be returned in batches.
    ///
    /// - Returns: an observable FolderContent
    func folderContentsBrowseViewModel() -> FolderBrowseViewModel
    
    /// Return a view model for a list of items in a folder. Contents might be returned in batches.
    ///
    /// - Parameter folder: folder for which to get the contents. May be left empty to start from the root.
    /// - Returns: an observable FolderContent
    func folderContentsBrowseViewModel(_ parentFolder: Folder) -> FolderBrowseViewModel

    /// Get an Artist object for the artist performing a particular song
    ///
    /// - Parameter song: the song for which to get the artist
    /// - Returns: an observable Artist
    func artistFromSong(_ song: Song) -> Observable<Artist>

    /// Get an Album object for the album on which a particular song appears
    ///
    /// - Parameter song: the song for which to get the album
    /// - Returns: an observable Album
    func albumFromSong(_ song: Song) -> Observable<Album>
    
    /// Preprocess a CoverURI. This allows additional processing of base URI data.
    ///
    /// - Parameter coverURI: the CoverURI to pre-process
    /// - Returns: the processed cover URI
    func preprocessCoverURI(_ coverURI: CoverURI) -> Observable<CoverURI>
}
