//
//  StatusProtocol.swift
//  ConnectorProtocol_iOS
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
    func playqueueSongs(start: Int, end: Int) -> [Song]
    
    /// Trigger a forced refresh of the status
    func forceStatusRefresh()
    
}
