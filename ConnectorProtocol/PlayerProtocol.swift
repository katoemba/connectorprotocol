//
//  PlayerProtocol.swift
//  ConnectorProtocol
//
//  Copyright 2018 - Katoemba Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import RxSwift
import RxCocoa

public enum ConnectionProperties: String {
    case Name = "Name"
    case Host = "Host"
    case Port = "Port"
    case Password = "Password"
}

/// A protocol to provide a generic interface to control a network music player.
public protocol PlayerProtocol: class {
    /// String that uniquely identifies a player. Implementation will be backend specific.
    var uniqueID: String { get }
    
    /// Name of a player. Implementation will be backend specific.
    var name: String { get }
    
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
}

public protocol PlayerBrowserProtocol {
    var addPlayerObservable : Observable<PlayerProtocol> { get }
    var removePlayerObservable : Observable<PlayerProtocol> { get }

    /// Start listening for players on the network.
    func startListening()
    
    /// Stop listening for players on the network.
    func stopListening()
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
