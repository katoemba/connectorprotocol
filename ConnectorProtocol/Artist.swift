//
//  Artist.swift
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

/// A struct defining a generic Artist object.
public struct Artist {
    /// A unique id for the artist. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this song (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Unknown
    
    /// The name of the artist.
    public var name = ""
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                name: String) {
        self.id = id
        self.source = source
        self.name = name
    }
}

extension Artist: Equatable {}
public func ==(lhs: Artist, rhs: Artist) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source
}

extension Artist: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

extension Artist: CustomStringConvertible {
    public var description: String {
        return "> Artist\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    name = \(name)\n"
    }
}

extension Artist: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Artist\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    name = \(name)\n"
    }
}
