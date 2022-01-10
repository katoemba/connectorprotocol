//
//  StatusProtocol.swift
//  ConnectorProtocol_iOS
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

/// The connection status
///
/// - Unknown: The status is unknown (probably not yet checked)
/// - Online: The player can be reached.
/// - Offline: The player is unreachable.
public enum ConnectionStatus {
    case unknown
    case online
    case offline
}

/// A protocol to provide a generic interface to observe / read the status from a music player.
public protocol StatusProtocol {
    /// An observable ConnectionStatus value
    var connectionStatusObservable: Observable<ConnectionStatus> { get }
    
    /// An observable PlayerStatus object
    var playerStatusObservable : Observable<PlayerStatus> { get }
    
    /// Get a block of songs from the playqueue
    ///
    /// - Parameters:
    ///   - start: the start position of the requested block
    ///   - end: the end position of the requested block
    /// - Returns: Array of songs, not guaranteed to have the same number of songs as requested.
    func playqueueSongs(start: Int, end: Int) -> Observable<[Song]>
    
    /// Get a block of song id's from the playqueue
    ///
    /// - Parameters:
    ///   - start: the start position of the requested block
    ///   - end: the end position of the requested block
    /// - Returns: Array of tuples of playqueue position and track id, not guaranteed to have the same number of songs as requested.
    func playqueueSongIds(start: Int, end: Int) -> Observable<[(Int, String)]>

    /// Trigger a forced refresh of the status
    func forceStatusRefresh()
}

public extension StatusProtocol {
    func playqueueSongIds(start: Int, end: Int) -> Observable<[(Int, String)]> {
        playqueueSongs(start: start, end: end)
            .map {
                $0.map {
                    ($0.position, $0.playqueueId ?? "0")
                }
            }
    }
}
