//
//  PlayerManagerTests.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 11-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import XCTest
import ConnectorProtocol

class PlayerManagerTests: XCTestCase {
    var observerArray = [NSObjectProtocol]()
    var notificationCount = 0

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.observerArray = [NSObjectProtocol]()
        self.notificationCount = 0
   }
    
    override func tearDown() {
        for observer in self.observerArray {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSettingInitialActivePlayer() {
        // Given no selected player
        PlayerManager.sharedPlayerManager.activePlayer = nil
        let newPlayer = PlayerMock()
        
        let notificationName = Notification.Name(rawValue: PlayerManagerNotification.ActivePlayerChanged.rawValue)
        let notificationHandler = { (notification: Notification) -> Bool in
            let player = notification.userInfo?["player"] as! PlayerProtocol
            XCTAssert(newPlayer.uniqueID == player.uniqueID, "Expected that player \(newPlayer.uniqueID) was passed in notification, instead got \(player.uniqueID)")
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler)
        
        // When a player is made active
        PlayerManager.sharedPlayerManager.activePlayer = newPlayer
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)

        // And the player is registered as the activePlayer
        XCTAssert(PlayerManager.sharedPlayerManager.activePlayer!.uniqueID == newPlayer.uniqueID, "Expected that player \(newPlayer.uniqueID) was made active, instead got \(PlayerManager.sharedPlayerManager.activePlayer!.uniqueID)")
    }

    func testSettingDifferentActivePlayer() {
        // Given a selected player
        PlayerManager.sharedPlayerManager.activePlayer = PlayerMock()
        let newPlayer = PlayerMock()
        newPlayer.uniqueID = "ID2"
        
        let notificationName = Notification.Name(rawValue: PlayerManagerNotification.ActivePlayerChanged.rawValue)
        let notificationHandler = { (notification: Notification) -> Bool in
            let player = notification.userInfo?["player"] as! PlayerProtocol
            XCTAssert(newPlayer.uniqueID == player.uniqueID, "Expected that player \(newPlayer.uniqueID) was passed in notification, instead got \(player.uniqueID)")
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler)
        
        // When a player is made active
        PlayerManager.sharedPlayerManager.activePlayer = newPlayer
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)
        
        // And the player is registered as the activePlayer
        XCTAssert(PlayerManager.sharedPlayerManager.activePlayer!.uniqueID == newPlayer.uniqueID, "Expected that player \(newPlayer.uniqueID) was made active, instead got \(PlayerManager.sharedPlayerManager.activePlayer!.uniqueID)")
    }

    func testSettingSameActivePlayer() {
        // Given a selected player
        PlayerManager.sharedPlayerManager.activePlayer = PlayerMock()
        
        let notificationName = Notification.Name(rawValue: PlayerManagerNotification.ActivePlayerChanged.rawValue)
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler))
        
        // When a player is made active
        let player = PlayerMock()
        PlayerManager.sharedPlayerManager.activePlayer = player
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            waitExpectation.fulfill()
        }
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(notificationCount == 0, "Unexpected notification received")
       
        // And the player is registered as the activePlayer
        XCTAssert(PlayerManager.sharedPlayerManager.activePlayer!.uniqueID == player.uniqueID, "Expected that player \(player.uniqueID) was made active, instead got \(PlayerManager.sharedPlayerManager.activePlayer!.uniqueID)")
    }

    func testClearingActivePlayer() {
        // Given a selected player
        PlayerManager.sharedPlayerManager.activePlayer = PlayerMock()
        
        let notificationName = Notification.Name(rawValue: PlayerManagerNotification.ActivePlayerChanged.rawValue)
        let notificationHandler = { (notification: Notification) -> Bool in
            XCTAssert(notification.userInfo?["player"] == nil, "Expected that no player was active")
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler)
        
        // When the active player is cleared
        PlayerManager.sharedPlayerManager.activePlayer = nil
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)
        
        // And the player is registered as the activePlayer
        XCTAssert(PlayerManager.sharedPlayerManager.activePlayer == nil, "Expected that no player was active")
    }
}
