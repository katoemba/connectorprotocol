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

public enum ConnectionStatus {
    case Unknown
    case Disconnected
    case Connecting
    case Connected
}

/// A protocol to provide a generic interface to control a network music player.
public protocol PlayerProtocol {
    /// String that uniquely identifies a player. Implementation will be backend specific.
    var uniqueID: String { get }
    
    /// Name of a player. Implementation will be backend specific.
    var name: String { get }
    
    /// Property to get the connection
    var connectionStatus: Driver<ConnectionStatus> { get }

    /// Property to get the connection parameters so they can be stored in User Defaults
    var connectionProperties: [String: Any] { get }
    
    /// Attempt to connect to a player. No return value as the implementation is most likely asynchronous
    func connect(numberOfRetries: Int)
    
    /// Get a controller object to control the player.
    var controller: ControlProtocol { get }
    
    /// Get a library object to browse music on the player
    //var library: LibraryProtocol { get }
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
    public init(player: PlayerProtocol) {
        self.player = player
    }
}

extension PlayerWrapper: Equatable {
    public static func ==(lhs: PlayerWrapper, rhs: PlayerWrapper) -> Bool {
        return lhs.player.uniqueID == rhs.player.uniqueID
    }
}
