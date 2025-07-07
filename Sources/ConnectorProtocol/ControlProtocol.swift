//
//  ControlProtocol.swift
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

public enum AddMode: String, Codable {
    case replace
    case addNext
    case addNextAndPlay
    case addAtEnd
}

public struct AddDetails {
    public let addMode: AddMode
    public let shuffle: Bool
    public let startWithSong: UInt32
    
    public init(_ addMode: AddMode, shuffle: Bool = false, startWithSong: UInt32 = 0) {
        self.addMode = addMode
        self.shuffle = shuffle
        self.startWithSong = startWithSong
    }
}

public struct AddResponse {
    public let addDetails: AddDetails
    public let playerStatus: PlayerStatus?
    
    public init(_ addDetails: AddDetails, _ playerStatus: PlayerStatus?) {
        self.addDetails = addDetails
        self.playerStatus = playerStatus
    }
}

public enum ControlError: Error {
    case notImplemented(function: String)
}

/// A protocol to provide a generic interface to control a music player.
public protocol ControlProtocol {
    func play() async throws -> PlayerStatus

    func play(index: Int) async throws -> PlayerStatus

    func pause() async throws -> PlayerStatus

    func stop() async throws -> PlayerStatus
    
    func togglePlayPause() async throws -> PlayerStatus

    func skip() async throws -> PlayerStatus
    
    func back() async throws -> PlayerStatus
    
    func add(_ album: Album, addDetails: AddDetails) async throws -> AddResponse
    
    func add(_ songs: [Song], addDetails: AddDetails) async throws -> AddResponse

    func setRandom(_ randomMode: RandomMode) async -> PlayerStatus
    
    func toggleRandom() async -> PlayerStatus
    
    func shufflePlayqueue() async -> PlayerStatus
    
    func setRepeat(_ repeatMode: RepeatMode) async -> PlayerStatus

    func toggleRepeat() async -> PlayerStatus
    
    func setConsume(_ consumeMode: ConsumeMode) async -> PlayerStatus
    
    func toggleConsume() async -> PlayerStatus
    
    func setVolume(_ volume: Float)async -> PlayerStatus

    func adjustVolume(_ adjustment: Float) async -> PlayerStatus

    func setSeek(seconds: UInt32) async -> PlayerStatus
    
    func setSeek(percentage: Float) async -> PlayerStatus

    func add(_ song: Song, addDetails: AddDetails) async -> (Song, AddResponse)

    func add(_ songs: [Song], addDetails: AddDetails) async -> (Song, AddResponse)
    
    func addToPlaylist(_ song: Song, playlist: Playlist) async

    func add(_ album: Album, addDetails: AddDetails) async -> (Album, AddResponse)

    func addToPlaylist(_ album: Album, playlist: Playlist) async
    
    func add(_ artist: Artist, addDetails: AddDetails) async -> (Artist, AddResponse)
    
    func add(_ playlist: Playlist, addDetails: AddDetails) async -> (Playlist, AddResponse)
    
    func add(_ genre: Genre, addDetails: AddDetails) async -> (Genre, AddResponse)
    
    func add(_ folder: Folder, addDetails: AddDetails) async -> (Folder, AddResponse)
    
    func addRecursive(_ folder: Folder, addDetails: AddDetails) async -> (Folder, AddResponse)

    func moveSong(from: Int, to: Int) async
    
    func deleteSong(_ at: Int) async
    
    func moveSong(playlist: Playlist, from: Int, to: Int) async
    
    func deleteSong(playlist: Playlist, at: Int) async
    
    func savePlaylist(_ name: String) async
    
    func clearPlayqueue(from: Int?, to: Int?) async -> PlayerStatus
    
    func playStation(_ station: Station) async -> PlayerStatus

    func playFavourite(_ favourite: FoundItem) async -> PlayerStatus

    func setOutput(_ output: Output, enabled: Bool) async -> PlayerStatus

    func toggleOutput(_ output: Output) async -> PlayerStatus
}
