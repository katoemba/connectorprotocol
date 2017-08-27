//
//  PlayerProtocol.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 11-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

public enum ConnectionStatus {
    case Disconnected
    case Connecting
    case Connected
}

public enum ConnectionStatusChangeNotification: String {
    case Connected = "ConnectionStatusChangeConnected"
    case Disconnected = "ConnectionStatusChangeDisconnected"
}

/// A protocol to provide a generic interface to control a network music player.
public protocol PlayerProtocol {
    /// String that uniquely identifies a player. Implementation will be backend specific.
    var uniqueID: String { get }
    
    /// Property to get the connection
    var connectionStatus: ConnectionStatus { get }

    /// Property to get the connection parameters so they can be stored in User Defaults
    var connectionProperties: [String: Any] { get }
    
    /// Attempt to connect to a player. No return value as the implementation is most likely asynchronous
    func connect(numberOfTries: Int)
    
    /// Get a controller object to control the player.
    var controller: ControlProtocol { get }
    
    /// Get a library object to browse music on the player
    //var library: LibraryProtocol { get }
}
