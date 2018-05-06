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
    case Name = "Name"
    case Host = "Host"
    case Port = "Port"
    case Password = "Password"
}

public enum DiscoverMode: String {
    case automatic = "automatic"
    case manual = "manual"
}

/// A protocol to provide a generic interface to control a network music player.
public protocol PlayerProtocol: class {
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
    
    /// Property to get the connection parameters so they can be stored in User Defaults
    var connectionProperties: [String: Any] { get }
    
    /// Optional description of the player
    var description: String { get }
    
    /// Property to get the version of a specific player
    var version: String { get }
    
    /// Activate a player. It shall initiate (long-)polling of status updates.
    func activate()
    
    /// Deactivate a plaer. It shall stop (long-)polling of status updates and close any open connections.
    func deactivate()
    
    /// Get a shared status object to monitor the player.
    var status: StatusProtocol { get }
    
    /// Get a control object to control the player.
    var control: ControlProtocol { get }
    
    /// Get a browse object to browse music on the player.
    var browse: BrowseProtocol { get }

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
}

public protocol PlayerBrowserProtocol {
    var addPlayerObservable : Observable<PlayerProtocol> { get }
    var removePlayerObservable : Observable<PlayerProtocol> { get }

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
