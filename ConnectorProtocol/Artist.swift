//
//  Artist.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

/// A struct defining a generic Artist object.
public struct Artist {
    /// A unique id for the artist. Usage depends on library implementation.
    var id = ""
    
    /// The name of the artist.
    var name = ""
    
    public init() {
    }
    
    public init(id: String,
                name: String) {
        self.id = id
        self.name = name
    }
}

extension Artist: Equatable {}
public func ==(lhs: Artist, rhs: Artist) -> Bool {
    return lhs.id == rhs.id
}

extension Artist: CustomStringConvertible {
    public var description: String {
        return "> Artist\n" +
            "    id = \(id)\n" +
            "    name = \(name)\n"
    }
}

extension Artist: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Artist\n" +
            "    id = \(id)\n" +
            "    name = \(name)\n"
    }
}
