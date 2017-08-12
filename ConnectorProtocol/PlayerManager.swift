//
//  PlayerManager.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 11-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

public enum PlayerManagerNotification: String {
    case ActivePlayerChanged = "ActivePlayerChanged"
}

public class PlayerManager {
    /// Singleton object
    public static let sharedPlayerManager = PlayerManager()
    
    /// Internal array of available players, from which a user can choose
    private var playerArray =  [PlayerProtocol]()
    
    /// Property for immutable list of available players
    public var availablePlayers: [PlayerProtocol] {
        get {
            return playerArray
        }
    }
    
    /// Property for the currently active player, which can be used throughout an application.
    public var activePlayer: PlayerProtocol? {
        didSet {
            if (oldValue == nil && activePlayer != nil) ||
                (oldValue != nil && activePlayer != nil && oldValue?.uniqueID != activePlayer?.uniqueID) {
                let notification = Notification.init(name: NSNotification.Name.init(PlayerManagerNotification.ActivePlayerChanged.rawValue), object: nil, userInfo: ["player": activePlayer!])
                NotificationCenter.default.post(notification)
            }
            else if oldValue != nil && activePlayer == nil {
                let notification = Notification.init(name: NSNotification.Name.init(PlayerManagerNotification.ActivePlayerChanged.rawValue), object: nil, userInfo: nil)
                NotificationCenter.default.post(notification)
            }
        }
    }
    
    /// Add a player to the list of available players
    ///
    /// - Parameter player: player to add to the list of available players.
    public func addPlayer(player: PlayerProtocol) {
        playerArray.append(player)
    }
}
