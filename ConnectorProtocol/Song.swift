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
    public init() {
    }
    
    /// A unique id for the song. Usage depends on library implementation.
    public var id = ""
    
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
}

extension Song: CustomStringConvertible {
    public var description: String {
        return "> Song\n" +
            "    id = \(id)\n" +
            "    title = \(title)\n"
    }
}

extension Song: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Song\n" +
            "    id = \(id)\n" +
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
