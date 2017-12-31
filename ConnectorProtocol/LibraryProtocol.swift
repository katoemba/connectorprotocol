//
//  LibraryProtocol.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public enum SourceType {
    case Unknown, Local, Spotify, TuneIn, Podcast
}

/// A protocol to provide a generic interface to a music library.
public protocol LibraryProtocol {
    /*
    /// Get a song by its unqiue ID.
    ///
    /// - Parameter songID: A string holding the unique ID of the song.
    /// - Returns: A fully populated Song object, or null in case no song is found for the provided id.
    func songById(_ songID: String) -> Song?
    
    /// Get a song by its location.
    ///
    /// - Parameter location: A strong holding the location of the song.
    /// - Returns: A fully populated Song object, or null in case no song is found for the provided location.
    func songByLocation(_ location: String) -> Song?
    
    /// Get an album by its unique ID.
    ///
    /// - Parameter albumID: A string holding the unique ID of the album.
    /// - Returns: A fully populated Album object, or null in case no album is found for the provided id.
    func albumById(_ albumID: String) -> Album?
    
    /// Get an album by its location.
    ///
    /// - Parameter location: A string holding the location of the album.
    /// - Returns: A fully populated Album object, or null in case no album is found for the provided location.
    func albumByLocation(_ location: String) -> Album?
    
    /// Get the songs on an album
    ///
    /// - Parameter album: An Album object.
    /// - Returns: An array of fully populated Song objects.
    func songsOnAlbum(_ album: Album) -> [Song]

    /// Get an artist by its unique ID.
    ///
    /// - Parameter artistID: A string holding the unique ID of the artist.
    /// - Returns: A fully populated Artist object, or null in case no artist is found for the provided id.
    func artistById(_ artistID: String) -> Artist?
    
    /// Get the albums released by an artist (based on albumartist).
    ///
    /// - Parameter artist: An Artist object.
    /// - Returns: An array of fully populated Album objects.
    func albumsByArtist(_ artist: Artist) -> [Album]

    /// Get the albums on which an artist appears.
    ///
    /// - Parameter artist: An Artist object.
    /// - Returns: An array of fully populated Album objects.
    func albumsOnWhichArtistAppears(_ artist: Artist) -> [Album]
    
    /// Get the songs performed by an artist.
    ///
    /// - Parameter artist: An Artist object.
    /// - Returns: An array of fully populated Song objects.
    func songsByArtist(_ artist: Artist) -> [Song]
     */
    
    /// Get the songs performed by an artist.
    ///
    /// - Parameter search: The text to search on.
    /// - Returns: A search object containing search results of different types.
    func search(_ search: String, limit: Int, filter: [SourceType]) -> SearchResult
}
