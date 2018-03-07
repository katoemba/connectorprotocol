//
//  Playlist.swift
//  ConnectorProtocol_iOS
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
