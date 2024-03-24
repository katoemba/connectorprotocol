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
import RxSwift

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

/// A protocol to provide a generic interface to control a music player.
public protocol ControlProtocol {
    /// Start playback.
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func play() -> Observable<PlayerStatus>
    
    /// Start playback of a specific track in the playqueue
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func play(index: Int)  -> Observable<PlayerStatus>
    
    /// Pause playback.
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func pause() -> Observable<PlayerStatus>
    
    /// Stop playback.
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func stop() -> Observable<PlayerStatus>
    
    /// Toggle between play and pause: when paused -> start to play, when playing -> pause.
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func togglePlayPause() -> Observable<PlayerStatus>
    
    /// Skip to the next track.
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func skip() -> Observable<PlayerStatus>
    
    /// Go back to the previous track.
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func back() -> Observable<PlayerStatus>
    
    /// Set the random mode of the player.
    ///
    /// - Parameter randomMode: The random mode to use.
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func setRandom(_ randomMode: RandomMode) -> Observable<PlayerStatus>
    
    /// Toggle the random mode (off -> on -> off)
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func toggleRandom() -> Observable<PlayerStatus>
    
    /// Shuffle the contents of the current playqueue.
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func shufflePlayqueue() -> Observable<PlayerStatus>
    
    /// Set the repeat mode of the player.
    ///
    /// - Parameter repeatMode: The repeat mode to use.
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func setRepeat(_ repeatMode: RepeatMode) -> Observable<PlayerStatus>

    /// Toggle the repeat mode (off -> all -> single -> off)
    ///
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func toggleRepeat() -> Observable<PlayerStatus>
    
    /// Set the consume mode of the player.
    ///
    /// - Parameter consumeMode: The consume mode to use.
    func setConsume(_ consumeMode: ConsumeMode)
    
    /// Toggle the consume mode (off -> on -> off)
    func toggleConsume()
    
    /// Set the volume of the player.
    ///
    /// - Parameter volume: The volume to set. Must be a value between 0.0 and 1.0, values outside this range will be ignored.
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func setVolume(_ volume: Float) -> Observable<PlayerStatus>

    /// Adjust the volume of the player.
    ///
    /// - Parameter adjustment: The adjustment to be made. Negative values will decrease the volume, positive values will increase the volume.
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func adjustVolume(_ adjustment: Float) -> Observable<PlayerStatus>

    /// Percentage at which the volume of the player reaches 50%, to adjust for skewed volume control of the player.
    /// If set to 20% for example, then 25% volume will set it to 10% on the player, and 75% will set it to 60% on the player.
    /// Must be a value between 0.1 and 0.9, values outside this range will be ignored. Pass nil to disable adjustment.
    var volumeAdjustment: Float? { get set }
    
    /// Seek to a position in the current song
    ///
    /// - Parameter seconds: seconds in the current song, must be <= length of the song
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func setSeek(seconds: UInt32) -> Observable<PlayerStatus>
    
    /// Seek to a relative position in the current song
    ///
    /// - Parameter percentage: relative position in the current song, must be between 0.0 and 1.0
    /// - Returns: an observable for the up-to-date playerStatus after the action is completed.
    func setSeek(percentage: Float) -> Observable<PlayerStatus>

    /// Add a song to the play queue
    ///
    /// - Parameters:
    ///   - song: the song to add
    ///   - addDetails: how to add the song to the playqueue
    /// - Returns: an observable tuple consisting of song and addResponse.
    func add(_ song: Song, addDetails: AddDetails) -> Observable<(Song, AddResponse)>

    /// Add a batch of songs to the play queue
    ///
    /// - Parameters:
    ///   - songs: array of songs to add
    ///   - addDetails: how to add the song to the playqueue
    /// - Returns: an observable tuple consisting of songs and addResponse.
    func add(_ songs: [Song], addDetails: AddDetails) -> Observable<([Song], AddResponse)>
    
    /// Add a song to a playlist
    ///
    /// - Parameters:
    ///   - song: the song to add
    ///   - playlist: the playlist to add the song to
    /// - Returns: an observable tuple consisting of song and playlist.
    func addToPlaylist(_ song: Song, playlist: Playlist) -> Observable<(Song, Playlist)>

    /// Add an album to the play queue
    ///
    /// - Parameters:
    ///   - album: the album to add
    ///   - addDetails: how to add the song to the playqueue
    /// - Returns: an observable tuple consisting of album and addResponse.
    func add(_ album: Album, addDetails: AddDetails) -> Observable<(Album, AddResponse)>

    /// Add an album to a playlist
    ///
    /// - Parameters:
    ///   - album: the album to add
    ///   - playlist: the playlist to add the song to
    /// - Returns: an observable tuple consisting of album and playlist.
    func addToPlaylist(_ album: Album, playlist: Playlist) -> Observable<(Album, Playlist)>
    
    /// Add an artist to the play queue
    ///
    /// - Parameters:
    ///   - artist: the artist to add
    ///   - addDetails: how to add the song to the playqueue
    /// - Returns: an observable tuple consisting of artist and addResponse.
    func add(_ artist: Artist, addDetails: AddDetails) -> Observable<(Artist, AddResponse)>
    
    /// Add a playlist to the play queue
    ///
    /// - Parameters:
    ///   - playlist: the playlist to add
    ///   - addDetails: how to add the playlist to the playqueue
    /// - Returns: an observable tuple consisting of playlist and addResponse.
    func add(_ playlist: Playlist, addDetails: AddDetails) -> Observable<(Playlist, AddResponse)>
    
    /// Add a genre to the play queue
    ///
    /// - Parameters:
    ///   - genre: the genre to add
    ///   - addDetails: how to add the folder to the playqueue
    /// - Returns: an observable tuple consisting of genre and addResponse.
    func add(_ genre: Genre, addDetails: AddDetails) -> Observable<(Genre, AddResponse)>
    
    /// Add a folder to the play queue
    ///
    /// - Parameters:
    ///   - folder: the folder to add
    ///   - addDetails: how to add the folder to the playqueue
    /// - Returns: an observable tuple consisting of folder and addResponse.
    func add(_ folder: Folder, addDetails: AddDetails) -> Observable<(Folder, AddResponse)>
    
    /// Add a folder recursively to the play queue
    ///
    /// - Parameters:
    ///   - folder: the folder to add
    ///   - addDetails: how to add the folder to the playqueue
    /// - Returns: an observable tuple consisting of folder and addResponse.
    func addRecursive(_ folder: Folder, addDetails: AddDetails) -> Observable<(Folder, AddResponse)>

    /// Move a song in the playqueue to a different position
    ///
    /// - Parameters:
    ///   - from: the position of the song to change
    ///   - to: the position to move the song to
    func moveSong(from: Int, to: Int)
    
    /// Remove song from the playqueue
    ///
    /// - Parameter at: the position of the song to remove
    func deleteSong(_ at: Int)
    
    /// Move a song in a playlist to a different position
    ///
    /// - Parameters:
    ///   - playlist: the playlist in which to make the move
    ///   - from: the position of the song to change
    ///   - to: the position to move the song to
    func moveSong(playlist: Playlist, from: Int, to: Int)
    
    /// Remove song from a playlist
    ///
    /// - Parameters:
    ///   - playlist: the playlist from which to remove the song
    ///   - at: the position of the song to remove
    func deleteSong(playlist: Playlist, at: Int)
    
    /// Save the current playqueue as a playlist
    ///
    /// - Parameter name: name for the playlist
    func savePlaylist(_ name: String)
    
    /// Clear the active playqueue
    func clearPlayqueue()
    
    /// Play a station
    ///
    /// - Parameter station: the station that has to be played
    func playStation(_ station: Station)

    /// Play a favourite
    ///
    /// - Parameter favourite: the favourite that has to be played
    func playFavourite(_ favourite: FoundItem)

    /// Enable or disable an output
    ///
    /// - Parameters:
    ///   - output: the output to set
    ///   - enabled: true to enable the output, false to disable it
    func setOutput(_ output: Output, enabled: Bool)

    /// Toggle an output on or off
    ///
    /// - Parameter output: the output to toggle
    func toggleOutput(_ output: Output)
}

extension ControlProtocol {
    public func playFavourite(_ favourite: FoundItem) {
        // Default does nothing
    }
    
    public var volumeAdjustment: Float? {
        get {
            return nil
        }
        set {
            
        }
    }
}
