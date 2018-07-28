//
//  Album.swift
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
    
    /// The sortation title of the album.
    public var sortTitle = ""
    
    /// The name of the artist(s) that released the album.
    public var artist = ""

    /// The sortation version of the artist(s) that released the album.
    public var sortArtist = ""
    
    /// The year the album was released.
    public var year = 0
    
    /// The name of the genre to which the album belongs.
    public var genre = [] as [String]

    /// The total duration of the album in seconds.
    public var length = 0
    
    /// URI through which cover art can be fetched.
    public var coverURI = CoverURI.fullPathURI("")

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
                genre: [String],
                length: Int,
                sortTitle: String = "",
                sortArtist: String = "") {
        self.id = id
        self.source = source
        self.location = location
        self.title = title
        self.artist = artist
        self.year = year
        self.genre = genre
        self.length = length
        self.sortTitle = sortTitle != "" ? sortTitle : title
        self.sortArtist = Artist.sortName(sortName: sortArtist, name: artist)
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
            "    coverURI = \(coverURI)\n" +
            "    sortTitle = \(sortTitle)\n" +
            "    sortArtist = \(sortArtist)\n"
    }
}
