//
//  Album.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

/// A struct defining a generic Album object.
public struct Album {
    /// A unique id for the album. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this song (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Unknown
    
    /// The location of the album. Usage depends on library implementation.
    public var location = ""

    /// The title of the album.
    public var title = ""
    
    /// The name of the artist(s) that released the album.
    public var artist = ""

    /// The year the album was released.
    public var year = 0
    
    /// The name of the genre to which the album belongs.
    public var genre = ""

    /// The total duration of the album in seconds.
    public var length = 0
    
    /// URI through which cover art can be fetched.
    public var coverURI = ""
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                location: String,
                title: String,
                artist: String,
                year: Int,
                genre: String,
                length: Int) {
        self.id = id
        self.source = source
        self.location = location
        self.title = title
        self.artist = artist
        self.year = year
        self.genre = genre
        self.length = length
    }
}

extension Album: Equatable {}
public func ==(lhs: Album, rhs: Album) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source
}

extension Album: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

extension Album: CustomStringConvertible {
    public var description: String {
        return "> Album\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    title = \(title)\n"
    }
}

extension Album: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Album\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    title = \(title)\n" +
            "    location = \(location)\n" +
            "    artist = \(artist)\n" +
            "    year = \(year)\n" +
            "    genre = \(genre)\n" +
            "    length = \(length)\n" +
            "    coverURI = \(coverURI)\n"
    }
}
