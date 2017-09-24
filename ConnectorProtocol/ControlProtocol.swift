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

/// A protocol to provide a generic interface to control a music player.
public protocol ControlProtocol {
    /// An observable playerStatus object
    var playerStatus : Driver<PlayerStatus> { get }
    
    /// A serial scheduler to allow performing serialized requests over a connection
    var serialScheduler: SerialDispatchQueueScheduler { get }
    
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

    /// Get the current player status
    ///
    /// - Returns: a filled PlayerStatus object
    func getPlayerStatus() -> PlayerStatus
    
    /// Get a block of songs from the playqueue
    ///
    /// - Parameters:
    ///   - start: the start position of the requested block
    ///   - end: the end position of the requested block
    /// - Returns: Array of songs, not guaranteed to have the same number of songs as requested.
    func getPlayqueueSongs(start: Int, end: Int) -> [Song]
}
