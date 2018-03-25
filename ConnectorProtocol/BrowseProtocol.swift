//
//  BrowseProtocol.swift
//  ConnectorProtocol
//
//  Copyright 2018 - Katoemba Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import RxSwift
import RxCocoa

public enum SourceType {
    case Unknown, Local, Spotify, TuneIn, Podcast
}

public enum SortType: String {
    case artist
    case year
    case yearReverse
}

public enum BrowseFilter {
    case genre(String)
    case artist(Artist)
    case album(Album)
    case playlist(Playlist)
    case recent(Int)
}

public protocol AlbumBrowseViewModel {
    var albumsObservable: Driver<[Album]> { get }
    var filters: [BrowseFilter] { get }
    var sort: SortType { get }
    var availableSortOptions: [SortType] { get }
    
    func load(sort: SortType)
    func load(filters: [BrowseFilter])
    func extend()
    func extend(to: Int)
}

public protocol ArtistBrowseViewModel {
    var artistsObservable: Driver<[Artist]> { get }
    var filters: [BrowseFilter] { get }
    
    func load()
    func extend()
}

public protocol PlaylistBrowseViewModel {
    var playlistsObservable: Driver<[Playlist]> { get }
    
    func load()
    func extend()
    
    func renamePlaylist(_ playlist: Playlist, to: String) -> Playlist
    func deletePlaylist(_ playlist: Playlist)
}

public protocol SongBrowseViewModel {
    var songsObservable: Driver<[Song]> { get }
    var filters: [BrowseFilter] { get }

    func load()
    func extend()
}

public protocol GenreBrowseViewModel {
    var genresObservable: Driver<[String]> { get }
    
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
    /// - Parameter artist: An Artist object.
    /// - Returns: An observable array of fully populated Album objects.
    func albumsByArtist(_ artist: Artist) -> Observable<[Album]>

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
    func artistBrowseViewModel() -> ArtistBrowseViewModel
    
    /// Return a view model for a list of artists filtered by genre, which can return artist in batches.
    ///
    /// - Parameter genre: genre to filter on
    /// - Returns: an ArtistBrowseViewModel instance
    func artistBrowseViewModel(_ genre: String) -> ArtistBrowseViewModel
    
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
}
