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
import RxSwift

public enum ConnectionProperties: String {
    case controllerType = "ControllerType"
    case name = "Name"
    case host = "Host"
    case port = "Port"
    case password = "Password"
    case binaryCoverArt = "BinaryCoverArt"
    case embeddedCoverArt = "EmbeddedCoverArt"
    case urlCoverArt = "URLCoverArt"
    case discogsCoverArt = "DiscogsCoverArt"
    case musicbrainzCoverArt = "MusicbrainzCoverArt"
}

public enum DiscoverMode: String {
    case automatic = "automatic"
    case manual = "manual"
}

public enum Functions {
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
}

/// A protocol to provide a generic interface to control a network music player.
public protocol PlayerProtocol: AnyObject {
    typealias FolderSettingAttachment = (Folder, PlayerSetting) -> (Void)
    
    /// Observable that triggers whenever something in the player is changed
    var playerChanged: Observable<PlayerProtocol> { get }
    
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
    
    /// A list of functions supported by the player
    var supportedFunctions: [Functions] { get }
    
    /// Property to get the connection parameters so they can be stored in User Defaults
    var connectionProperties: [String: Any] { get }
    
    /// Optional description of the player
    var description: String { get }
    
    /// Property to get the version of a specific player
    var version: String { get }
    
    /// Property to get an optional connection warning of a specific player, like incompatible version
    var connectionWarning: String? { get }
    
    /// Optional property to return a list of settings that be set to a folder, used for UPnP
    var folderAttachmentSettings: [PlayerSetting]? { get }
    
    /// Optional action to connect a folder to a setting
    var attachFolderToSetting: FolderSettingAttachment? { get }
    
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
    
    /// Get a copy of the player object.
    func copy() -> PlayerProtocol
    
    /// Get the player specific settings definitions.
    /// A client can implement a generic settings page from these definitions.
    var settings: [PlayerSettingGroup] { get }
    
    /// Store setting.value into user-defaults and perform any other required actions
    ///
    /// - Parameter setting: the settings definition, including the value
    func updateSetting(_ setting: PlayerSetting)
    
    /// Get data for a specific setting
    ///
    /// - Parameter id: the id of the setting to load
    /// - Returns: a new PlayerSetting object containing the value of the requested setting, or nil if the setting is unknown
    func loadSetting(id: String) -> PlayerSetting?
    
    /// Load favourites from a player
    /// - Returns: an observable array of items
    func favourites() -> Observable<[FoundItem]>
    
    /// Check if a player is reachable
    func ping() async -> Bool
}

/// Extension to include optional functions and properties, to maintain some form of backwards compatibility
public extension PlayerProtocol {
    var playerStreamURL: URL? {
        return nil
    }
    
    var folderAttachmentSettings: [PlayerSetting]? {
        return nil
    }
    
    var attachFolderToSetting: FolderSettingAttachment? {
        return nil
    }

    var playerChanged: Observable<PlayerProtocol> {
        Observable.just(self)
    }
    
    /// Default is that a player automatically has media available (like mpd, kodi).
    var mediaAvailable: Bool {
        true
    }
    
    var mediaServerModel: String {
        "Embedded media server"
    }

    var mediaServers: [BrowseProtocol] {
        return [browse]
    }
    
    func selectMediaServer(_ mediaServer: BrowseProtocol, source: SourceType) {
        // Do nothing by default.
    }

    func favourites() -> Observable<[FoundItem]> {
        return Observable.empty()
    }
    
    func browse(source: SourceType) -> BrowseProtocol? {
        if source == .Local {
            return browse
        }
        return nil
    }
}

public protocol PlayerBrowserProtocol {
    /// String that identifies the Controller Type.
    var controllerType: String { get }

    var addPlayerObservable : Observable<PlayerProtocol> { get }
    var removePlayerObservable : Observable<PlayerProtocol> { get }
    var changedPlayerObservable: Observable<PlayerProtocol> { get }

    /// Start listening for players on the network.
    func startListening()
    
    /// Stop listening for players on the network.
    func stopListening()

    /// Manually create a player based on the connection properties
    ///
    /// - Parameter connectionProperties: dictionary of connection properties
    /// - Returns: An observable on which a created Player can published.
    func playerForConnectionProperties(_ connectionProperties: [String: Any]) -> Observable<PlayerProtocol?>
    
    /// Persist a manually added player in user defaults
    ///
    /// - Parameter connectionProperties: the connection properties for the player
    func persistPlayer(_ connectionProperties: [String: Any])

    /// Remove a manually added player from user defaults
    ///
    /// - Parameter player: the player to remove
    func removePlayer(_ player: PlayerProtocol)

    /// Get the specific settings to add a player manually.
    /// A client can implement a generic add manual player view from these definitions.
    var addManualPlayerSettings: [PlayerSettingGroup] { get }
}

public extension PlayerBrowserProtocol {
    var changedPlayerObservable: Observable<PlayerProtocol> {
        Observable.empty()
    }
}

/// This wrapper class is a work-around for Swift restrictions on Protocols and Associated Types.
public class PlayerWrapper {
    public let player: PlayerProtocol
    public init(_ player: PlayerProtocol) {
        self.player = player
    }
}

extension PlayerWrapper: Equatable {
    public static func ==(lhs: PlayerWrapper, rhs: PlayerWrapper) -> Bool {
        return lhs.player.uniqueID == rhs.player.uniqueID
    }
}
