//
//  Artist.swift
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

public enum ArtistType {
    case artist
    case albumArtist
    case performer
    case composer
}

/// A struct defining a generic Artist object.
public struct Artist: Identifiable {
    /// A unique id for the artist. Usage depends on library implementation.
    public var id = ""
    
    /// The type of artist, this type is used generically for artists, performers and composers
    public var type = ArtistType.artist
    
    /// The source of this song (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Unknown
    
    /// The name of the artist.
    public var name = ""
    
    /// The sortation name of the artist.
    public var sortName = ""
    
    /// URI through which cover art can be fetched.
    public var coverURI = CoverURI.fullPathURI("")

    public init() {
    }
    
    public init(id: String,
                type: ArtistType = .artist,
                source: SourceType,
                name: String,
                sortName: String = "") {
        self.id = id
        self.type = type
        self.source = source
        self.name = name
        self.sortName = Artist.sortName(sortName: sortName, name: name)
    }
    
    static func sortName(sortName: String, name: String) -> String {
        if sortName != "" {
            if sortName != "The The" && (sortName.starts(with: "The ") || sortName.starts(with: "the ")) {
                return "\(sortName.dropFirst(4)), The"
            }
            else {
                return sortName
            }
        }
        else {
            if name != "The The" && (name.starts(with: "The ") || name.starts(with: "the ")) {
                return "\(name.dropFirst(4)), The"
            }
            else {
                return name
            }
        }
    }
    
    public func filter(_ filter: String) -> Bool {
        return name.uppercased().contains(filter.uppercased())
    }
}

extension Artist: Equatable {}
public func ==(lhs: Artist, rhs: Artist) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source && lhs.type == rhs.type
}

extension Artist: Hashable {
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

extension Artist: CustomStringConvertible {
    public var description: String {
        return "> Artist\n" +
            "    id = \(id)\n" +
            "    type = \(type)\n" +
            "    source = \(source)\n" +
            "    name = \(name)\n" +
            "    sortName = \(sortName)\n"
    }
}

extension Artist: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Artist\n" +
            "    id = \(id)\n" +
            "    type = \(type)\n" +
            "    name = \(name)\n" +
            "    sortName = \(sortName)\n"
    }
}
