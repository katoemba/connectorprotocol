//
//  PlayerProtocol.swift
//  ConnectorProtocol
//
// The MIT License (MIT)
//
// Copyright (c) 2018 Katoemba Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import SwiftUI

public enum DiscoverMode: String {
    case automatic = "automatic"
    case manual = "manual"
}

public enum Functions: CaseIterable {
    case randomSongs
    case twentyRandomSongs  // Allow to specify a smaller number of random songs for performance reasons
    case randomAlbums
    case composers
    case performers
    case conductors
    case quality
    case recentlyAddedAlbums
    case recentlyPlayedAlbums
    case recentlyAddedSongs
    case recentlyPlayedSongs
    case binaryImageRetrieval
    case embeddedImageRetrieval
    case stream
    case favourites
    case playlists
    case tidal
    case qobuz
    case radio
    case volumeAdjustment
    case mediaServerBrowsing
    case consume
    case repeatSingle
    case playRecursiveFolder
}

public struct PlayerDefinition: Identifiable, Equatable, Hashable, Sendable, Codable {
    public var id: String
    public var name: String
    public var type: String
    public var typeSpecificData: Data
    
    public init(id: String, name: String, type: String, typeSpecificData: Data) {
        self.id = id
        self.name = name
        self.type = type
        self.typeSpecificData = typeSpecificData
    }
    
    public static func == (lhs: PlayerDefinition, rhs: PlayerDefinition) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
    }
}

/// A protocol to provide a generic interface to control a network music player.
///
@preconcurrency
public protocol PlayerProtocol: AnyObject {
    /// String that identifies the Controller Type.
    var controllerType: String { get }
    
    /// How the player was discovered.
    var discoverMode: DiscoverMode { get }
    
    /// String that uniquely identifies a player. Implementation will be backend specific.
    var uniqueID: String { get }
    
    /// Name of a player. Implementation will be backend specific.
    var name: String { get }
    
    /// Description of the model of player. Implementation will be backend specific.
    var model: String { get }
    
    /// Description of the model of an associated media player. Implementation will be backend specific.
    var mediaServerModel: String { get }

    /// Whether the player shall be hidden.
    var hidden: Bool { get }
    
    /// A list of functions supported by the player
    var supportedFunctions: [Functions] { get }
    
    /// Optional description of the player
    var description: String { get }
    
    /// Property to get the version of a specific player
    var version: String { get }
    
    /// Property to get an optional connection warning of a specific player, like incompatible version
    var connectionWarning: String? { get }
    
    /// Property that specifies whether browsable media are available
    var mediaAvailable: Bool { get }
    
    /// Property that specifies which media servers are available. This is useful in case there are more than 1 data sources.
    var mediaServers: [BrowseProtocol] { get }
    
    /// Activate a player. It shall initiate (long-)polling of status updates.
    func activate()
    
    /// Deactivate a plaer. It shall stop (long-)polling of status updates and close any open connections.
    func deactivate()
    
    /// Get a shared status object to monitor the player.
    var status: StatusProtocol { get }
    
    /// Get a control object to control the player.
    var control: ControlProtocol { get }
    
    /// Get a browse object to browse local music on the player.
    var browse: BrowseProtocol { get }
    
    /// Get a browse object to browse a specific source on the player. There will be a default implementation that returns nil
    func browse(source: SourceType) -> BrowseProtocol?
    
    /// Select a specific media server for a given source.
    func selectMediaServer(_ mediaServer: BrowseProtocol, source: SourceType)
    
    /// Get the url on which the player is providing an audio stream
    var playerStreamURL: URL? { get }
    
    /// Load favourites from a player
    /// - Returns: an observable array of items
    func favourites() async throws -> [FoundItem]
    
    /// Check if a player is reachable
    func ping() async -> Bool
    
    func playerDefinition() throws -> PlayerDefinition
    
    associatedtype SettingsView: View
    @ViewBuilder func settingsView(deleteAction: ((any PlayerProtocol) -> ())?,
                                   hideAction: ((any PlayerProtocol) -> ())?) -> SettingsView
}

extension PlayerProtocol {
    public func defaultsKey(_ key: String) -> String {
        key + "." + uniqueID
    }
}

public protocol PlayerBrowserProtocol {
    /// String that identifies the Controller Type.
    var controllerType: String { get }

    /// Stream with player discovery lifecycle events.
    var playerEventStream: AsyncStream<PlayerBrowserEvent> { get }

    var players: [any PlayerProtocol] { get }

    /// Start listening for players on the network.
    func startListening(predefinedPlayers: [PlayerDefinition]) async
    
    /// Stop listening for players on the network.
    func stopListening() async

    func decodePlayer(_ playerDefinition: PlayerDefinition) async throws -> any PlayerProtocol
    
    associatedtype ManualAddPlayerView: View
    @ViewBuilder func manualAddPlayerView() -> ManualAddPlayerView
}

public enum PlayerBrowserEvent {
    case added(any PlayerProtocol)
    case removed(PlayerDefinition)
    case updated(any PlayerProtocol)
}
