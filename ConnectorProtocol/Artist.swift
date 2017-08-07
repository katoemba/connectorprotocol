//
//  Artist.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

/// A struct defining a generic Artist object.
struct Artist {
    /// A unique id for the artist. Usage depends on library implementation.
    var id = ""
    
    /// The name of the artist.
    var name = ""
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
