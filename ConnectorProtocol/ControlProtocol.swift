//
//  ControlProtocol.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public enum AddMode {
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
    func toggleRandom(from: RandomMode)
    
    /// Shuffle the contents of the current playqueue.
    func shufflePlayqueue()
    
    /// Set the repeat mode of the player.
    ///
    /// - Parameter repeatMode: The repeat mode to use.
    func setRepeat(repeatMode: RepeatMode)

    /// Toggle the repeat mode (off -> all -> single -> off)
    func toggleRepeat(from: RepeatMode)
    
    /// Set the volume of the player.
    ///
    /// - Parameter volume: The volume to set. Must be a value between 0.0 and 1.0, values outside this range will be ignored.
    func setVolume(volume: Float)

    /// Add a song to the play queue
    ///
    /// - Parameters:
    ///   - song: the song to add
    ///   - addMode: how to add the song to the playqueue
    func addSong(_ song: Song, addMode: AddMode)

    /// Add an album to the play queue
    ///
    /// - Parameters:
    ///   - album: the album to add
    ///   - addMode: how to add the song to the playqueue
    ///   - shuffle: whether or not to shuffle the album
    func addAlbum(_ album: Album, addMode: AddMode, shuffle: Bool)
}
