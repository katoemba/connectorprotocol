//
//  PlayerStatusTests.swift
//  PlayerStatusTests
//
//  Created by Berrie Kremers on 08-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import XCTest
import ConnectorProtocol

class DataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
     }
    
    func testSongEqual() {
        // When song1 and song2 have the same id
        let song1 = Song(id: "123",
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: "genre",
                         length: 100,
                         bitrate: "bitrate",
                         encoding: "encoding")
        let song2 = Song(id: "123",
                         location: "locationx",
                         title: "titlex",
                         album: "albumx",
                         artist: "artistx",
                         albumartist: "albumartistx",
                         composer: "composerx",
                         year: 1001,
                         genre: "genrex",
                         length: 101,
                         bitrate: "bitratex",
                         encoding: "encodingx")
        
        // Then they are treated equal
        XCTAssert(song1 == song2, "song comparison failed for songs with the same id")
    }

    func testSongNotEqual() {
        // When song1 and song2 have a different id
        let song1 = Song(id: "123",
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: "genre",
                         length: 100,
                         bitrate: "bitrate",
                         encoding: "encoding")
        let song2 = Song(id: "345",
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: "genrex=",
                         length: 100,
                         bitrate: "bitrate",
                         encoding: "encoding")
        
        // Then they are treated as not equal
        XCTAssertFalse(song1 == song2, "song comparison failed for songs with different id")
    }
    
    func testAlbumEqual() {
        // When song1 and song2 have the same id
        let album1 = Album(id: "123",
                         location: "location",
                         title: "title",
                         artist: "artist",
                         year: 1000,
                         genre: "genre",
                         length: 100)
        let album2 = Album(id: "123",
                         location: "locationx",
                         title: "titlex",
                         artist: "artistx",
                         year: 1001,
                         genre: "genrex",
                         length: 101)
        
        // Then they are treated equal
        XCTAssert(album1 == album2, "album comparison failed for albums with the same id")
    }
    
    func testAlbumNotEqual() {
        // When song1 and song2 have a different id
        let artist1 = Album(id: "123",
                           location: "location",
                           title: "title",
                           artist: "artist",
                           year: 1000,
                           genre: "genre",
                           length: 100)
        let artist2 = Album(id: "345",
                           location: "location",
                           title: "title",
                           artist: "artist",
                           year: 1000,
                           genre: "genre",
                           length: 100)
        
        // Then they are treated as not equal
        XCTAssertFalse(artist1 == artist2, "artist comparison failed for artists with different id")
    }

    func testArtistEqual() {
        // When song1 and song2 have the same id
        let artist1 = Artist(id: "123",
                             name: "name")
        let artist2 = Artist(id: "123",
                             name: "namex")
        
        // Then they are treated equal
        XCTAssert(artist1 == artist2, "artist comparison failed for artists with the same id")
    }
    
    func testArtistNotEqual() {
        // When song1 and song2 have a different id
        let album1 = Artist(id: "123",
                            name: "name")
        let album2 = Artist(id: "345",
                            name: "name")
        
        // Then they are treated as not equal
        XCTAssertFalse(album1 == album2, "album comparison failed for albums with different id")
    }

    func testTimeStatus() {
        var time = TimeStatus.init()
        time.elapsedTime = 10
        time.trackTime = 25
        
        XCTAssert(time.elapsedTimeString == "0:10", "ElapsedTimeString: expected 0:10, got \(time.elapsedTimeString)")
        XCTAssert(time.trackTimeString == "0:25", "TrackTimeString: expected 0:25, got \(time.trackTimeString)")
        XCTAssert(time.remainingTimeString == "0:15", "RemainingTimeString: expected 0:15, got \(time.remainingTimeString)")

        time.elapsedTime = 100
        time.trackTime = 250
        
        XCTAssert(time.elapsedTimeString == "1:40", "ElapsedTimeString: expected 1:40, got \(time.elapsedTimeString)")
        XCTAssert(time.trackTimeString == "4:10", "TrackTimeString: expected 4:10, got \(time.trackTimeString)")
        XCTAssert(time.remainingTimeString == "2:30", "RemainingTimeString: expected 2:20, got \(time.remainingTimeString)")

        time.elapsedTime = 1000
        time.trackTime = 2500
        
        XCTAssert(time.elapsedTimeString == "16:40", "ElapsedTimeString: expected 16:40, got \(time.elapsedTimeString)")
        XCTAssert(time.trackTimeString == "41:40", "TrackTimeString: expected 41:40, got \(time.trackTimeString)")
        XCTAssert(time.remainingTimeString == "25:00", "RemainingTimeString: expected 25:00, got \(time.remainingTimeString)")
    }
}
