//
//  StreamingCollection.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 25/08/2026.
//

import Foundation

/// A struct defining a generic Streaming Collection object.
/// This identifies streaming service specific collections, e.g. what friends listen to, recent, popular
public struct StreamingCollection: Codable, Sendable, Identifiable, Hashable {
    public init(id: String = "", source: SourceType = .Unknown, name: String = "") {
        self.id = id
        self.source = source
        self.name = name
    }
    
    /// A unique id for the streaming collection. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this streaming collection (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Unknown
    
    /// The name of the streaming collection.
    public var name = ""
}
