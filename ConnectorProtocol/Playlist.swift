//
//  Playlist.swift
//  ConnectorProtocol_iOS
//
//  Created by Berrie Kremers on 04-03-18.
//  Copyright © 2018 Kaotemba Software. All rights reserved.
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
