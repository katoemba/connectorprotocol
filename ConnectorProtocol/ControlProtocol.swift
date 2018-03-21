//
//  ControlProtocol.swift
//  ConnectorProtocol
//
//  Copyright 2018 - Katoemba Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import RxSwift
import RxCocoa

public enum AddMode: String {
    case replace
    case addNext
    case addNextAndPlay
    case addAtEnd
}

/// A protocol to provide a generic interface to control a music player.
public protocol ControlProtocol {
    /// Start playback.
    func play()
    
    /// Start playback of a specific track in the playqueue
    func play(index: Int)
    
    /// Pause playback.
    func pause()
    
    /// Toggle between play and pause: when paused -> start to play, when playing -> pause.
    func togglePlayPause()
    
    /// Skip to the next track.
    func skip()
    
    /// Go back to the previous track.
    func back()
    
    /// Set the random mode of the player.
    ///
    /// - Parameter randomMode: The random mode to use.
    func setRandom(randomMode: RandomMode)
    
    /// Toggle the random mode (off -> on -> off)
    func toggleRandom()
    
    /// Shuffle the contents of the current playqueue.
    func shufflePlayqueue()
    
    /// Set the repeat mode of the player.
    ///
    /// - Parameter repeatMode: The repeat mode to use.
    func setRepeat(repeatMode: RepeatMode)

    /// Toggle the repeat mode (off -> all -> single -> off)
    func toggleRepeat()
    
    /// Set the volume of the player.
    ///
    /// - Parameter volume: The volume to set. Must be a value between 0.0 and 1.0, values outside this range will be ignored.
    func setVolume(volume: Float)
    
    /// Seek to a position in the current song
    ///
    /// - Parameter seconds: seconds in the current song, must be <= length of the song
    func setSeek(seconds: UInt32)
    
    /// Seek to a relative position in the current song
    ///
    /// - Parameter percentage: relative position in the current song, must be between 0.0 and 1.0
    func setSeek(percentage: Float)

    /// Add a song to the play queue
    ///
    /// - Parameters:
    ///   - song: the song to add
    ///   - addMode: how to add the song to the playqueue
    func addSong(_ song: Song, addMode: AddMode)

    /// Add a batch of songs to the play queue
    ///
    /// - Parameters:
    ///   - songs: array of songs to add
    ///   - addMode: how to add the song to the playqueue
    func addSongs(_ songs: [Song], addMode: AddMode)
    
    /// Add an album to the play queue
    ///
    /// - Parameters:
    ///   - album: the album to add
    ///   - addMode: how to add the song to the playqueue
    ///   - shuffle: whether or not to shuffle the album
    func addAlbum(_ album: Album, addMode: AddMode, shuffle: Bool, startWithSong: UInt32)

    /// Add an artist to the play queue
    ///
    /// - Parameters:
    ///   - artist: the artist to add
    ///   - addMode: how to add the song to the playqueue
    ///   - shuffle: whether or not to shuffle the artist
    func addArtist(_ artist: Artist, addMode: AddMode, shuffle: Bool)
    
    /// Add a playlist to the play queue
    ///
    /// - Parameters:
    ///   - playlist: the playlist to add
    ///   - addMode: how to add the song to the playqueue
    ///   - shuffle: whether or not to shuffle the playlist
    func addPlaylist(_ playlist: Playlist, addMode: AddMode, shuffle: Bool, startWithSong: UInt32)
    
    /// Add a genre to the play queue
    ///
    /// - Parameters:
    ///   - genre: the genre to add
    ///   - addMode: how to add the song to the playqueue
    ///   - shuffle: whether or not to shuffle the genre
    func addGenre(_ genre: String, addMode: AddMode, shuffle: Bool)
    
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
    
    /// Save the current playqueue as a playlist
    ///
    /// - Parameter name: name for the playlist
    func savePlaylist(_ name: String)
}
