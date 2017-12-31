//
//  SearchResult.swift
//  ConnectorProtocol_iOS
//
//  Created by Berrie Kremers on 30-09-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

public enum LibraryItem {
    case song(Song)
    case album(Album)
    case artist(Artist)
}

public struct SearchResult {
    public var songs = [Song]()
    public var albums = [Album]()
    public var artists = [Artist]()
    
    public init() {
    }
}
