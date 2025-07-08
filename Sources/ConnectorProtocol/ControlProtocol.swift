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
    public let playerStatus: PlayerStatus
    
    public init(_ addMode: AddMode, shuffle: Bool = false, startWithSong: UInt32 = 0, playerStatus: PlayerStatus) {
        self.addMode = addMode
        self.shuffle = shuffle
        self.startWithSong = startWithSong
        self.playerStatus = playerStatus
    }
}

public enum ControlError: Error {
    case notImplemented(function: String)
}

/// A protocol to provide a generic interface to control a music player.
public protocol ControlProtocol {
    func play() async throws

    func play(index: Int) async throws

    func pause() async throws

    func stop() async throws
    
    func togglePlayPause() async throws

    func skip() async throws
    
    func back() async throws
    
    func add(_ album: Album, addDetails: AddDetails) async throws
    
    func add(_ songs: [Song], addDetails: AddDetails) async throws

    func setRandom(_ randomMode: RandomMode) async throws
    
    func toggleRandom() async throws
    
    func shufflePlayqueue() async throws
    
    func setRepeat(_ repeatMode: RepeatMode) async throws

    func toggleRepeat() async throws
    
    func setConsume(_ consumeMode: ConsumeMode) async throws
    
    func toggleConsume() async throws
    
    func setVolume(_ volume: Float)async throws

    func adjustVolume(_ adjustment: Float) async throws

    func setSeek(seconds: UInt32) async throws
    
    func setSeek(percentage: Float) async throws

    func add(_ song: Song, addDetails: AddDetails) async throws
    
    func addToPlaylist(_ song: Song, playlist: Playlist) async throws

    func addToPlaylist(_ album: Album, playlist: Playlist) async throws
    
    func add(_ artist: Artist, addDetails: AddDetails) async throws
    
    func add(_ playlist: Playlist, addDetails: AddDetails) async throws
    
    func add(_ genre: Genre, addDetails: AddDetails) async throws
    
    func add(_ folder: Folder, addDetails: AddDetails) async throws
    
    func addRecursive(_ folder: Folder, addDetails: AddDetails) async throws

    func moveSong(from: Int, to: Int) async throws
    
    func deleteSong(_ at: Int) async throws
    
    func moveSong(playlist: Playlist, from: Int, to: Int) async throws
    
    func deleteSong(playlist: Playlist, at: Int) async throws
    
    func savePlaylist(_ name: String) async throws
    
    func clearPlayqueue(from: Int?, to: Int?) async throws
    
    func playStation(_ station: Station) async throws
    
    func playFavourite(_ favourite: FoundItem) async throws

    func setOutput(_ output: Output, enabled: Bool) async throws

    func toggleOutput(_ output: Output) async throws
}
