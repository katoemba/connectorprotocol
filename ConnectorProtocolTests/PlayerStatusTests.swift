//
//  PlayerStatusTests.swift
//  PlayerStatusTests
//
//  Created by Berrie Kremers on 08-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import XCTest
import ConnectorProtocol

class PlayerStatusTests: XCTestCase {
    var playerStatus = PlayerStatus()
    var observerArray = [NSObjectProtocol]()
    var notificationCount = 0
    let songID = "12345"
    let songIndex = 20
    let songTitle = "Creature Comfort"
    let album = "Everything Now"
    let artist = "Arcade Fire"
    let volume = Float(0.6)
    let trackTime = 100
    let elapsedTime = 50
    let bitrate = "48.0Khz"
    let encoding = "192bits"
    let station = "3FM"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.playerStatus = PlayerStatus()
        self.observerArray = [NSObjectProtocol]()
        self.notificationCount = 0
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        for observer in self.observerArray {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// Test that no notifications are sent when not using beginUpdate / endUpdate
    func testNoNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.SongInfo.rawValue)
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        let notificationHandler = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler))
        
        // When a PlayerStatus value is changed without enclosing beginUpdates/endUpdates
        let operation = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.song = self.songTitle
        })
        operation.start()

        // Then no notification is sent
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.song == songTitle, "Song title incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }

    func testSongInfoNotificationForSongID() {
        // Given a freshly initialized PlayerStatus object (from setUp)

        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.SongInfo.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.songID == self.songID, "Song ID incorrect")
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus songID value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.songID = self.songID
            self.playerStatus.endUpdate()
        })
        operation1.start()

        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")

        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When songID is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.songID = self.songID
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.songID == songID, "Song ID incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }
    
    func testSongInfoNotificationForSong() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.SongInfo.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.song == self.songTitle, "Song title incorrect")
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus song value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.song = self.songTitle
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")

        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When song is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.song = self.songTitle
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.song == songTitle, "Song title incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }

    func testSongInfoNotificationForArtist() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.SongInfo.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.artist == self.artist, "Artist incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus artist value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.artist = self.artist
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When artist is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.artist = self.artist
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.artist == artist, "Artist incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }

    func testSongInfoNotificationForAlbum() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.SongInfo.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.album == self.album, "Album incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus album value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.album = self.album
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")

        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When album is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.album = self.album
            self.playerStatus.endUpdate()
        })
        operation2.start()
        waitForExpectations(timeout: 0.4, handler: nil)
        
        // Then no notification is received
        XCTAssert(playerStatus.album == album, "Album incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }

    func testSongInfoNotificationForSongIndex() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.SongInfo.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.songIndex == self.songIndex, "Song index incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus songIndex value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.songIndex = self.songIndex
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When songIndex is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.songIndex = self.songIndex
            self.playerStatus.endUpdate()
        })
        operation2.start()

        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.songIndex == songIndex, "Song index incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }
    
    func testSingleSongInfoNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.SongInfo.rawValue)
        let waitExpectation = expectation(description: "Waiting for single notification")

        // When multiple PlayerStatus song related values are changed
        let notificationHandler = { (notification: Notification) in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.song == self.songTitle, "Song title incorrect")
            XCTAssert(playerStatus.artist == self.artist, "Artist incorrect")
            XCTAssert(playerStatus.album == self.album, "Album incorrect")
            XCTAssert(playerStatus.songID == self.songID, "Song ID incorrect")
            XCTAssert(playerStatus.songIndex == self.songIndex, "Song index incorrect")
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler))

        let operation = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }

            self.playerStatus.beginUpdate()
            self.playerStatus.song = self.songTitle
            self.playerStatus.songID = self.songID
            self.playerStatus.artist = self.artist
            self.playerStatus.album = self.album
            self.playerStatus.songIndex = self.songIndex
            self.playerStatus.endUpdate()
        })
        operation.start()
        
        // Then one notification of type PlayerStatusChangeNotification.SongInfo is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
    }

    func testPlayingStatusNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.PlayingStatus.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.playingStatus == .Playing, "Playing Status incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus PlayingStatus value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.playingStatus = .Playing
            self.playerStatus.endUpdate()
        })
        operation1.start()

        // Then one notification of type PlayerStatusChangeNotification.PlayingStatus is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When PlayingStatus is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.playingStatus = .Playing
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.playingStatus == .Playing, "Playing Status incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }
    
    func testVolumeNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.Volume.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.volume == self.volume, "Volume incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus Volume value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.volume = self.volume
            self.playerStatus.endUpdate()
        })
        operation1.start()

        // Then one notification of type PlayerStatusChangeNotification.Volume is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When volume is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.volume = self.volume
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.volume == self.volume, "Volume incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }

    func testRepeatNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.RepeatMode.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.repeatMode == .All, "Repeat mode incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus RepeatMode value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.repeatMode = .All
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.RepeatMode is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object

        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When repeatMode is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.repeatMode = .All
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.repeatMode == .All, "Repeat mode incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }

    func testShuffleNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)

        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.ShuffleMode.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.shuffleMode == .On, "Shuffle mode incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus ShuffleMode value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.shuffleMode = .On
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.ShuffleMode is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When shuffleMode is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.shuffleMode = .On
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.shuffleMode == .On, "Shuffle mode incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }

    func testStationInfoNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.StationInfo.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.station == self.station, "Station incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus station value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.station = self.station
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.StationInfo is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When station is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.station = self.station
            self.playerStatus.endUpdate()
        })
        operation2.start()

        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.station == self.station, "Station incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }
    
    func testTrackTimeNotificationForTrackTime() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.TrackTime.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.trackTime == self.trackTime, "Track time incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus trackTime value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.trackTime = self.trackTime
            self.playerStatus.endUpdate()
        })
        operation1.start()

        // Then one notification of type PlayerStatusChangeNotification.TrackTime is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When trackTime is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.trackTime = self.trackTime
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.trackTime == trackTime, "Track time incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }
    
    func testTrackTimeNotificationForElapsedTime() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.TrackTime.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.elapsedTime == self.elapsedTime, "Elapsed time incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus elapsedTime value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.elapsedTime = self.elapsedTime
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.TrackTime is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When elapsedTime is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.elapsedTime = self.elapsedTime
            self.playerStatus.endUpdate()
        })
        operation2.start()

        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.elapsedTime == elapsedTime, "Elapsed time incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }
    
    func testSingleTrackTimeNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.TrackTime.rawValue)
        let waitExpectation = expectation(description: "Waiting for single notification")
        let notificationHandler = { (notification: Notification) in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.trackTime == self.trackTime, "Track time incorrect")
            XCTAssert(playerStatus.elapsedTime == self.elapsedTime, "Elapsed time incorrect")
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler))
        
        // When PlayerStatus trackTime and elapsedTime value are changed
        let operation = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            
            self.playerStatus.beginUpdate()
            self.playerStatus.trackTime = self.trackTime
            self.playerStatus.elapsedTime = self.elapsedTime
            self.playerStatus.endUpdate()
        })
        operation.start()
        
        // Then one notification of type PlayerStatusChangeNotification.TrackTime is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
    }

    func testQualityNotificationForBitrate() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.Quality.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.bitrate == self.bitrate, "Bitrate incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus bitrate value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.bitrate = self.bitrate
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.Quality is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When bitrate is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.bitrate = self.bitrate
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.bitrate == bitrate, "Bitrate incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }
    
    func testQualityNotificationForEncoding() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.Quality.rawValue)
        let notificationHandler1 = { (notification: Notification) -> Bool in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.encoding == self.encoding, "Encoding incorrect")
            
            return true
        }
        expectation(forNotification: notificationName.rawValue, object: nil, handler: notificationHandler1)
        
        // When PlayerStatus encoding value is changed
        let operation1 = BlockOperation(block: {
            self.playerStatus.beginUpdate()
            self.playerStatus.encoding = self.encoding
            self.playerStatus.endUpdate()
        })
        operation1.start()
        
        // Then one notification of type PlayerStatusChangeNotification.Quality is received
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
        
        // Given the updated PlayerStatus object
        
        let waitExpectation = expectation(description: "Waiting for (no) notification")
        notificationCount = 0
        let notificationHandler2 = { (notification: Notification) in
            self.notificationCount += 1
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler2))
        
        // When encoding is updated to the same value
        let operation2 = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            self.playerStatus.beginUpdate()
            self.playerStatus.encoding = self.encoding
            self.playerStatus.endUpdate()
        })
        operation2.start()
        
        // Then no notification is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(playerStatus.encoding == encoding, "Encoding incorrect")
        XCTAssert(notificationCount == 0, "Unexpected notification received")
    }
    
    func testSingleQualityNotification() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName = Notification.Name(rawValue: PlayerStatusChangeNotification.Quality.rawValue)
        let waitExpectation = expectation(description: "Waiting for single notification")
        let notificationHandler = { (notification: Notification) in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.bitrate == self.bitrate, "Bitrate incorrect")
            XCTAssert(playerStatus.encoding == self.encoding, "Encoding incorrect")
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: notificationHandler))
        
        // When PlayerStatus bitrate and encoding value are changed
        let operation = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            
            self.playerStatus.beginUpdate()
            self.playerStatus.bitrate = self.bitrate
            self.playerStatus.encoding = self.encoding
            self.playerStatus.endUpdate()
        })
        operation.start()
        
        // Then one notification of type PlayerStatusChangeNotification.Quality is received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(notificationCount == 1, "Incorrect number of notifications received")
    }

    func testMultipleNotifications() {
        // Given a freshly initialized PlayerStatus object (from setUp)
        
        let notificationName1 = Notification.Name(rawValue: PlayerStatusChangeNotification.Quality.rawValue)
        let notificationName2 = Notification.Name(rawValue: PlayerStatusChangeNotification.SongInfo.rawValue)
        let notificationName3 = Notification.Name(rawValue: PlayerStatusChangeNotification.Volume.rawValue)
        let notificationName4 = Notification.Name(rawValue: PlayerStatusChangeNotification.TrackTime.rawValue) // Listening, but should not be triggered
        let waitExpectation = expectation(description: "Waiting for 3 notifications")
        let notificationHandler = { (notification: Notification) in
            self.notificationCount += 1
            let playerStatus = notification.userInfo?["status"] as! PlayerStatus
            
            XCTAssert(playerStatus.bitrate == self.bitrate, "Bitrate incorrect")
            XCTAssert(playerStatus.encoding == self.encoding, "Encoding incorrect")
            XCTAssert(playerStatus.album == self.album, "Album incorrect")
            XCTAssert(playerStatus.artist == self.artist, "Artist incorrect")
            XCTAssert(playerStatus.volume == self.volume, "Volume incorrect")
        }
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName1, object: nil, queue: nil, using: notificationHandler))
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName2, object: nil, queue: nil, using: notificationHandler))
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName3, object: nil, queue: nil, using: notificationHandler))
        observerArray.append(NotificationCenter.default.addObserver(forName: notificationName4, object: nil, queue: nil, using: notificationHandler))
        
        // When PlayerStatus bitrate, encoding, album, artist and volume value are changed
        let operation = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitExpectation.fulfill()
            }
            
            self.playerStatus.beginUpdate()
            self.playerStatus.bitrate = self.bitrate
            self.playerStatus.encoding = self.encoding
            self.playerStatus.album = self.album
            self.playerStatus.artist = self.artist
            self.playerStatus.volume = self.volume
            self.playerStatus.endUpdate()
        })
        operation.start()
        
        // Then three notifications are received
        waitForExpectations(timeout: 0.4, handler: nil)
        XCTAssert(notificationCount == 3, "Incorrect number of notifications received")
    }
}
