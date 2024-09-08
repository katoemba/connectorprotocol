//
// Product: 
// Package: 
//
// Created by Berrie Kremers on 02/09/2024
// Copyright © 2018-2023 Katoemba Software. All rights reserved.
//
	

import Foundation
import RxSwift

public extension PlayerProtocol {
    func currentStatus() async throws -> PlayerStatus? {
        try await status.playerStatusObservable.take(1).asSingle().value
    }
}

public extension StatusProtocol {
    func playqueueSongs(start: Int, end: Int) async -> [Song] {
        (try? await playqueueSongs(start: start, end: end).asMaybe().value) ?? []
    }
    
    func getStatus() async -> PlayerStatus? {
        try? await getStatus().asMaybe().value
    }
}

public extension ControlProtocol {
    func play() async throws -> PlayerStatus {
        try await play().asSingle().value
    }
    
    func pause() async throws -> PlayerStatus {
        try await pause().asSingle().value
    }
    
    func skip() async throws -> PlayerStatus {
        try await skip().asSingle().value
    }
    
    func adjustVolume(_ adjustment: Float) async throws -> PlayerStatus {
        try await adjustVolume(adjustment).asSingle().value
    }
}
