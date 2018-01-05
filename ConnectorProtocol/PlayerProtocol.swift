//
//  PlayerProtocol.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 11-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
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
