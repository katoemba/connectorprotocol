//
//  Artist.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Katoemba Software. All rights reserved.
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
