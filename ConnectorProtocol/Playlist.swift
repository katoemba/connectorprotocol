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
public struct Playlist {
    /// A unique id for the playlist. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this song (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Unknown
    
    /// The name of the playlist.
    public var name = ""
    
    /// The date the playlist was last modified
    public var lastModified = Date(timeIntervalSince1970: 0)
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                name: String,
                lastModified: Date) {
        self.id = id
        self.source = source
        self.name = name
        self.lastModified = lastModified
    }
}

extension Playlist: Equatable {}
public func ==(lhs: Playlist, rhs: Playlist) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source
}

extension Playlist: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

extension Playlist: CustomStringConvertible {
    public var description: String {
        return "> Playlist\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    name = \(name)\n" +
        "    lastModified = \(lastModified)\n"
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
