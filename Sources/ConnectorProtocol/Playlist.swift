//
//  Playlist.swift
//  ConnectorProtocol_iOS
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

/// A struct defining a generic Playlist object.
public struct Playlist: Codable, Sendable {
    /// A unique id for the playlist. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this song (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Unknown
    
    /// The name of the playlist.
    public var name = ""
    
    /// The date the playlist was last modified
    public var lastModified = Date(timeIntervalSince1970: 0)
    
    /// The total duration of the playlist in seconds
    public var duration: UInt32?
    
    /// The number of songs in the playlist
    public var numberOfSongs: UInt32?
    
    /// An image to show for this playlist
    public var image: CoverURI?

    /// A small image to show for this playlist
    public var miniImage: CoverURI?

    /// A list of genres included in this playlist
    public var genres: [String]?
    
    /// A description of the content of the playlist
    public var description: String?
    
    /// Whether the user can make changes to this playlist
    public var editable: Bool = true
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                name: String,
                lastModified: Date,
                editable: Bool = true,
                duration: UInt32? = nil,
                numberOfSongs: UInt32? = nil,
                image: CoverURI? = nil,
                miniImage: CoverURI? = nil,
                genres: [String]? = nil,
                description: String? = nil) {
        self.id = id
        self.source = source
        self.name = name
        self.lastModified = lastModified
        self.editable = editable
        self.duration = duration
        self.numberOfSongs = numberOfSongs
        self.image = image
        self.miniImage = miniImage
        self.genres = genres
        self.description = description
    }
}

extension Playlist: Equatable {}
public func ==(lhs: Playlist, rhs: Playlist) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source
}

extension Playlist: Hashable {
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

extension Playlist: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Playlist\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    name = \(name)\n" +
        "    lastModified = \(lastModified)\n"
    }
}
