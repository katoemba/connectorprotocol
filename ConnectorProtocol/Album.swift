//
//  Album.swift
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

    /// Date the album was last modified.
    public var lastModified = Date(timeIntervalSince1970: 0)

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
