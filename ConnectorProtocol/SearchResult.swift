//
//  SearchResult.swift
//  ConnectorProtocol_iOS
//
//  Created by Berrie Kremers on 30-09-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

public enum LibraryItemType {
    case Song,
    Album,
    Artist
}

public struct LibraryItem {
    public var itemType: LibraryItemType
    public var song: Song?
    public var album: Album?
    public var artist: Artist?

    public static func Song(_ song: Song) -> LibraryItem {
        return LibraryItem(itemType: .Song, song: song, album: nil, artist: nil)
    }

    public static func Album(_ album: Album) -> LibraryItem {
        return LibraryItem(itemType: .Album, song: nil, album: album, artist: nil)
    }

    public static func Artist(_ artist: Artist) -> LibraryItem {
        return LibraryItem(itemType: .Artist, song: nil, album: nil, artist: artist)
    }
}

public struct SearchResult {
    public var songs = [Song]()
    public var albums = [Album]()
    public var artists = [Artist]()
    
    public init() {
    }
}
