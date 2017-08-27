//
//  Album.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

/// A struct defining a generic Album object.
public struct Album {
    /// A unique id for the album. Usage depends on library implementation.
    var id = ""
    
    /// The location of the album. Usage depends on library implementation.
    var location = ""

    /// The title of the album.
    var title = ""
    
    /// The name of the artist(s) that released the album.
    var artist = ""

    /// The year the album was released.
    var year = 0
    
    /// The name of the genre to which the album belongs.
    var genre = ""

    /// The total duration of the album in seconds.
    var length = 0
}

extension Album: CustomStringConvertible {
    public var description: String {
        return "> Album\n" +
            "    id = \(id)\n" +
            "    title = \(title)\n"
    }
}

extension Album: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Album\n" +
            "    id = \(id)\n" +
            "    title = \(title)\n" +
            "    location = \(location)\n" +
            "    artist = \(artist)\n" +
            "    year = \(year)\n" +
            "    genre = \(genre)\n" +
            "    length = \(length)\n"
    }
}
