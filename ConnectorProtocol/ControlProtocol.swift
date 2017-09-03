//
//  ControlProtocol.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation
import RxSwift

/// A protocol to provide a generic interface to control a music player.
public protocol ControlProtocol {
    /// A playerStatus object with observable sub-elements
    var observablePlayerStatus: ObservablePlayerStatus { get }
    
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
    
    /// Set the shuffle mode of the player.
    ///
    /// - Parameter shuffleMode: The shuffle mode to use.
    func setShuffle(shuffleMode: ShuffleMode)
    
    /// Set the repeat mode of the player.
    ///
    /// - Parameter repeatMode: The repeat mode to use.
    func setRepeat(repeatMode: RepeatMode)

    /// Set the volume of the player.
    ///
    /// - Parameter volume: The volume to set. Must be a value between 0.0 and 1.0, values outside this range will be ignored.
    func setVolume(volume: Float)

    /// Get a block of songs from the playqueue
    ///
    /// - Parameters:
    ///   - start: the start position of the requested block
    ///   - end: the end position of the requested block
    ///   - songsFound: block that will be called upon completion. The [Song] parameter is not guaranteed to have the same number
    ///     of songs as requested.
    func getPlayqueueSongs(start: Int, end: Int,
                           songsFound: @escaping (([Song]) -> Void))
    
    func playqueueSongs(start: Int, fetchSize: Int) -> Observable<[Song]>
}
