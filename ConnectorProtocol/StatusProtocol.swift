//
//  StatusProtocol.swift
//  ConnectorProtocol_iOS
//
//  Created by Berrie Kremers on 03-01-18.
//  Copyright © 2018 Katoemba Software. All rights reserved.
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
    var connectionStatusObservable: Driver<ConnectionStatus> { get }
    
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
