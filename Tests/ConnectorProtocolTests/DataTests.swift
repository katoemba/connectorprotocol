//
//  PlayerStatusTests.swift
//  PlayerStatusTests
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
        // When song1 and song2 have the same id and source
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus())
        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1001,
                         genre: ["genre"],
                         length: 101,
                         quality: QualityStatus())

        // Then they are treated equal
        XCTAssert(song1 == song2, "song comparison failed for songs with the same id")
    }

    func testSongNotEqual() {
        // When song1 and song2 have a different id
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus())
        let song2 = Song(id: "345",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genrex="],
                         length: 100,
                         quality: QualityStatus())

        // Then they are treated as not equal
        XCTAssertFalse(song1 == song2, "song comparison failed for songs with different id")
    }
    
    func testSongEqualBasedOnPlayqueueId() {
        // When song1 and song2 have the same id and source
        let song1 = Song(id: "12233",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "albumx",
                         artist: "artistx",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         playqueueId: "1234")
        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1001,
                         genre: ["genre"],
                         length: 101,
                         quality: QualityStatus(),
                         playqueueId: "1234")

        // Then they are treated equal
        XCTAssert(song1 == song2, "song comparison failed for songs with the same playqueue id")
    }

    func testSongNotEqualBasedOnPlayqueueId() {
        // When song1 and song2 have a different id
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         playqueueId: "4567")
        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1001,
                         genre: ["genre"],
                         length: 101,
                         quality: QualityStatus(),
                         playqueueId: "1234")

        // Then they are treated as not equal
        XCTAssertFalse(song1 == song2, "song comparison failed for songs with different playqueueId")
    }
    
    func testSongDifferentSourceNotEqual() {
        // When song1 and song2 have a different source
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus())
        let song2 = Song(id: "123",
                         source: .Spotify,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genrex="],
                         length: 100,
                         quality: QualityStatus())

        // Then they are treated as not equal
        XCTAssertFalse(song1 == song2, "song comparison failed for songs with different id")
    }
    
    func testSongDifferentTitleNotEqual() {
        // When song1 and song2 have a different source
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus())
        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "titlex",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genrex="],
                         length: 100,
                         quality: QualityStatus())

        // Then they are treated as not equal
        XCTAssertFalse(song1 == song2, "song comparison failed for songs with different id")
    }
    
    func testSongDifferentAlbumNotEqual() {
        // When song1 and song2 have a different source
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus())
        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "albumx",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genrex="],
                         length: 100,
                         quality: QualityStatus())

        // Then they are treated as not equal
        XCTAssertFalse(song1 == song2, "song comparison failed for songs with different id")
    }
    
    func testSongDifferentArtistNotEqual() {
        // When song1 and song2 have a different source
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus())
        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artistx",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genrex="],
                         length: 100,
                         quality: QualityStatus())

        // Then they are treated as not equal
        XCTAssertFalse(song1 == song2, "song comparison failed for songs with different id")
    }
    
    func testAlbumEqual() {
        // When song1 and song2 have the same id and source
        let album1 = Album(id: "123",
                           source: .Local,
                           location: "location",
                         title: "title",
                         artist: "artist",
                         year: 1000,
                         genre: ["genre"],
                         length: 100)
        let album2 = Album(id: "123",
                           source: .Local,
                         location: "locationx",
                         title: "titlex",
                         artist: "artistx",
                         year: 1001,
                         genre: ["genrex"],
                         length: 101)
        
        // Then they are treated equal
        XCTAssert(album1 == album2, "album comparison failed for albums with the same id")
    }
    
    func testAlbumNotEqual() {
        // When song1 and song2 have a different id
        let artist1 = Album(id: "123",
                            source: .Local,
                           location: "location",
                           title: "title",
                           artist: "artist",
                           year: 1000,
                           genre: ["genre"],
                           length: 100)
        let artist2 = Album(id: "345",
                            source: .Local,
                           location: "location",
                           title: "title",
                           artist: "artist",
                           year: 1000,
                           genre: ["genre"],
                           length: 100)
        
        // Then they are treated as not equal
        XCTAssertFalse(artist1 == artist2, "artist comparison failed for artists with different id")
    }

    func testAlbumDifferentSourceNotEqual() {
        // When song1 and song2 have a different source
        let artist1 = Album(id: "123",
                            source: .Local,
                            location: "location",
                            title: "title",
                            artist: "artist",
                            year: 1000,
                            genre: ["genre"],
                            length: 100)
        let artist2 = Album(id: "123",
                            source: .Spotify,
                            location: "location",
                            title: "title",
                            artist: "artist",
                            year: 1000,
                            genre: ["genre"],
                            length: 100)
        
        // Then they are treated as not equal
        XCTAssertFalse(artist1 == artist2, "artist comparison failed for artists with different id")
    }
    
    func testArtistEqual() {
        // When song1 and song2 have the same id
        let artist1 = Artist(id: "123",
                             source: .Local,
                             name: "name")
        let artist2 = Artist(id: "123",
                             source: .Local,
                             name: "namex")
        
        // Then they are treated equal
        XCTAssert(artist1 == artist2, "artist comparison failed for artists with the same id")
    }
    
    func testArtistNotEqual() {
        // When song1 and song2 have a different id
        let album1 = Artist(id: "123",
                            source: .Local,
                            name: "name")
        let album2 = Artist(id: "345",
                            source: .Local,
                            name: "name")
        
        // Then they are treated as not equal
        XCTAssertFalse(album1 == album2, "album comparison failed for albums with different id")
    }

    func testArtistDifferentSourceNotEqual() {
        // When song1 and song2 have a different id
        let album1 = Artist(id: "123",
                            source: .Local,
                            name: "name")
        let album2 = Artist(id: "123",
                            source: .Spotify,
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
    
    func testArtistSort() {
        let arcadeFire = Artist(id: "Arcade Fire", type: .artist, source: .Local, name: "Arcade Fire", sortName: "Arcade Fire")
        XCTAssert(arcadeFire.sortName == "Arcade Fire", "sortName: expected 'Arcade Fire', got \(arcadeFire.sortName)")

        let foetus = Artist(id: "Scraping Foetus off the Wheel", type: .artist, source: .Local, name: "Scraping Foetus off the Wheel", sortName: "Foetus")
        XCTAssert(foetus.sortName == "Foetus", "sortName: expected 'Foetus', got \(foetus.sortName)")

        let replacements = Artist(id: "The Replacements", type: .artist, source: .Local, name: "The Replacements", sortName: "")
        XCTAssert(replacements.sortName == "Replacements, The", "sortName: expected 'Replacements, The', got \(replacements.sortName)")

        let huskerdu = Artist(id: "Hüsker Dü", type: .artist, source: .Local, name: "Hüsker Dü", sortName: "")
        XCTAssert(huskerdu.sortName == "Hüsker Dü", "sortName: expected 'Hüsker Dü', got \(huskerdu.sortName)")
    }
    
    func testAlbumSort() {
        let arcadeFire = Album(id: "Everything Now", source: .Local, location: "/a/b", title: "Everything Now", artist: "Everything Now", year: 2000, genre: ["Alternative"], length: 3000, sortTitle: "Everything Now", sortArtist: "Arcade Fire")
        XCTAssert(arcadeFire.sortArtist == "Arcade Fire", "sortName: expected 'Arcade Fire', got \(arcadeFire.sortArtist)")
        XCTAssert(arcadeFire.sortTitle == "Everything Now", "sortName: expected 'Everything Now', got \(arcadeFire.sortTitle)")

        let foetus = Album(id: "Nail", source: .Local, location: "/a/b", title: "Nail", artist: "Scraping Foetus off the Wheel", year: 2000, genre: ["Alternative"], length: 3000, sortTitle: "Hole", sortArtist: "Foetus")
        XCTAssert(foetus.sortArtist == "Foetus", "sortName: expected 'Foetus', got \(foetus.sortArtist)")
        XCTAssert(foetus.sortTitle == "Hole", "sortName: expected 'Hole', got \(foetus.sortTitle)")

        let replacements = Album(id: "Tim", source: .Local, location: "/a/b", title: "Tim", artist: "The Replacements", year: 2000, genre: ["Alternative"], length: 3000, sortTitle: "", sortArtist: "")
        XCTAssert(replacements.sortArtist == "Replacements, The", "sortName: expected 'Replacements, The', got \(replacements.sortArtist)")
        XCTAssert(replacements.sortTitle == "Tim", "sortName: expected 'Tim', got \(replacements.sortTitle)")

        let huskerdu = Album(id: "Flip your Wig", source: .Local, location: "/a/b", title: "Flip your Wig", artist: "Hüsker Dü", year: 2000, genre: ["Alternative"], length: 3000, sortTitle: "", sortArtist: "")
        XCTAssert(huskerdu.sortArtist == "Hüsker Dü", "sortName: expected 'Hüsker Dü', got \(huskerdu.sortArtist)")
        XCTAssert(huskerdu.sortTitle == "Flip your Wig", "sortName: expected 'Flip your Wig', got \(huskerdu.sortTitle)")
    }
    
    func testAlbumFromSong() {
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         sortArtist: "sortartist",
                         sortAlbumArtist: "sortalbumartist",
                         sortAlbum: "sortalbum")

        var album = song1.createAlbum()
        XCTAssertEqual(album.id, "\(SourceType.Local.rawValue)::albumartist::album")
        XCTAssertEqual(album.artist, "albumartist")
        XCTAssertEqual(album.title, "album")
        XCTAssertEqual(album.sortArtist, "sortalbumartist")
        XCTAssertEqual(album.sortTitle, "sortalbum")
        XCTAssertEqual(album.genre, ["genre"])

        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         sortArtist: "sortartist",
                         sortAlbumArtist: "",
                         sortAlbum: "sortalbum")

        album = song2.createAlbum()
        XCTAssertEqual(album.id, "\(SourceType.Local.rawValue)::artist::album")
        XCTAssertEqual(album.artist, "artist")
        XCTAssertEqual(album.title, "album")
        XCTAssertEqual(album.sortArtist, "sortartist")
        XCTAssertEqual(album.sortTitle, "sortalbum")
        XCTAssertEqual(album.genre, ["genre"])
    }
    
    func testArtistFromSong() {
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         sortArtist: "sortartist",
                         sortAlbumArtist: "sortalbumartist",
                         sortAlbum: "sortalbum")

        var artist = song1.createArtist(type: .albumArtist)
        XCTAssertNotNil(artist)
        XCTAssertEqual(artist!.id, "\(SourceType.Local.rawValue)::albumartist")
        XCTAssertEqual(artist!.type, .albumArtist)
        XCTAssertEqual(artist!.name, "albumartist")
        XCTAssertEqual(artist!.sortName, "sortalbumartist")

        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         sortArtist: "sortartist",
                         sortAlbumArtist: "",
                         sortAlbum: "sortalbum")

        artist = song2.createArtist(type: .albumArtist)
        XCTAssertNotNil(artist)
        XCTAssertEqual(artist!.id, "\(SourceType.Local.rawValue)::artist")
        XCTAssertEqual(artist!.type, .albumArtist)
        XCTAssertEqual(artist!.name, "artist")
        XCTAssertEqual(artist!.sortName, "sortartist")
    }
    
    func testExtendedNames() {
        let song1 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         sortArtist: "sortartist",
                         sortAlbumArtist: "sortalbumartist",
                         sortAlbum: "sortalbum")

        XCTAssertEqual(song1.extendedSortAlbum, "sortalbum")
        XCTAssertEqual(song1.extendedSortArtist, "sortartist")
        XCTAssertEqual(song1.extendedAlbumArtist, "albumartist")
        XCTAssertEqual(song1.extendSortAlbumArtist, "sortalbumartist")

        let song2 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         sortArtist: "",
                         sortAlbumArtist: "",
                         sortAlbum: "")

        XCTAssertEqual(song2.extendedSortAlbum, "album")
        XCTAssertEqual(song2.extendedSortArtist, "artist")
        XCTAssertEqual(song2.extendedAlbumArtist, "artist")
        XCTAssertEqual(song2.extendSortAlbumArtist, "artist")

        let song3 = Song(id: "123",
                         source: .Local,
                         location: "location",
                         title: "title",
                         album: "album",
                         artist: "artist",
                         albumartist: "albumartist",
                         composer: "composer",
                         year: 1000,
                         genre: ["genre"],
                         length: 100,
                         quality: QualityStatus(),
                         sortArtist: "",
                         sortAlbumArtist: "",
                         sortAlbum: "")

        XCTAssertEqual(song3.extendedSortAlbum, "album")
        XCTAssertEqual(song3.extendedSortArtist, "artist")
        XCTAssertEqual(song3.extendedAlbumArtist, "albumartist")
        XCTAssertEqual(song3.extendSortAlbumArtist, "albumartist")
    }
}
