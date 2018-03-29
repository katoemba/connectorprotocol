//
//  PlayerStatus.swift
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
import RxCocoa

public enum PlayPauseMode {
    case Paused
    case Playing
    case Stopped
}

public enum RandomMode {
    case Off
    case On
}

public enum ShuffleMode {
    case Off
    case On
}

public enum RepeatMode {
    case Off
    case Single
    case All
    case Album
}

// MARK: - TimeStatus struct

public struct TimeStatus {
    public var elapsedTime = Int(0)
    public var trackTime = Int(0)
    
    public var elapsedTimeString : String {
        get {
            return "\(Int(elapsedTime / 60)):\(String(format: "%02d", Int(elapsedTime % 60)))"
        }
    }
    public var trackTimeString : String {
        get {
            return "\(Int(trackTime / 60)):\(String(format: "%02d", Int(trackTime % 60)))"
        }
    }
    public var remainingTimeString : String {
        get {
            let remainingTime = trackTime - elapsedTime
            return "\(Int(remainingTime / 60)):\(String(format: "%02d", Int(remainingTime % 60)))"
        }
    }
    
    public init() {
    }
    
    public init(_ from: TimeStatus) {
        elapsedTime = from.elapsedTime
        trackTime = from.trackTime
    }
}
extension TimeStatus: Equatable {}
public func ==(lhs: TimeStatus, rhs: TimeStatus) -> Bool {
    return lhs.elapsedTime == rhs.elapsedTime &&
        lhs.trackTime == rhs.trackTime
}
extension TimeStatus: CustomStringConvertible {
    public var description: String {
        return "> Time\n" +
            "    trackTime = \(trackTime)\n" +
            "    elapsedTime = \(elapsedTime)\n"
    }
}
extension TimeStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> PlayerStatus\n" +
            "    trackTime = \(trackTime)\n" +
            "    elapsedTime = \(elapsedTime)\n"
    }
}

// MARK: - QualityStatus Struct

public struct QualityStatus {
    public var bitrate = ""
    public var encoding = ""

    public init() {
    }

    public init(_ from: QualityStatus) {
        bitrate = from.bitrate
        encoding = from.encoding
    }
}
extension QualityStatus: Equatable {}
public func ==(lhs: QualityStatus, rhs: QualityStatus) -> Bool {
    return lhs.bitrate == rhs.bitrate &&
        lhs.encoding == rhs.encoding
}
extension QualityStatus: CustomStringConvertible {
    public var description: String {
        return "> QualityStatus\n" +
            "    bitrate = \(bitrate)\n" +
        "    encoding = \(encoding)\n"
    }
}
extension QualityStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> QualityStatus\n" +
            "    bitrate = \(bitrate)\n" +
        "    encoding = \(encoding)\n"
    }
}

// MARK: - PlayqueueStatus Struct

public struct PlayqueueStatus {
    public var songIndex = 0
    public var version = 0
    public var length = 0

    public init() {
    }

    public init(_ from: PlayqueueStatus) {
        songIndex = from.songIndex
        version = from.version
        length = from.length
    }
}
extension PlayqueueStatus: Equatable {}
public func ==(lhs: PlayqueueStatus, rhs: PlayqueueStatus) -> Bool {
    return lhs.songIndex == rhs.songIndex &&
        lhs.version == rhs.version &&
        lhs.length == rhs.length
}
extension PlayqueueStatus: CustomStringConvertible {
    public var description: String {
        return "> PlayqueueStatus\n" +
            "    songIndex = \(songIndex)\n" +
            "    version = \(version)\n" +
        "    length = \(length)\n"
    }
}
extension PlayqueueStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> PlayqueueStatus\n" +
            "    songIndex = \(songIndex)\n" +
            "    version = \(version)\n" +
        "    length = \(length)\n"
    }
}

// MARK: - PlayStatus Struct

public struct PlayStatus {
    public var playPauseMode = PlayPauseMode.Paused
    public var randomMode = RandomMode.Off
    public var repeatMode = RepeatMode.Off

    public init() {
    }

    public init(_ from: PlayStatus) {
        playPauseMode = from.playPauseMode
        randomMode = from.randomMode
        repeatMode = from.repeatMode
    }
}
extension PlayStatus: Equatable {}
public func ==(lhs: PlayStatus, rhs: PlayStatus) -> Bool {
    return lhs.playPauseMode == rhs.playPauseMode &&
        lhs.randomMode == rhs.randomMode &&
        lhs.repeatMode == rhs.repeatMode
}
extension PlayStatus: CustomStringConvertible {
    public var description: String {
        return "> PlayStatus\n" +
            "    playingStatus = \(playPauseMode)\n" +
            "    repeatMode = \(repeatMode)\n" +
        "    randomMode = \(randomMode)\n"
    }
}
extension PlayStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> PlayStatus\n" +
            "    playingStatus = \(playPauseMode)\n" +
            "    repeatMode = \(repeatMode)\n" +
        "    randomMode = \(randomMode)\n"
    }
}

/// A PlayerStatus object containing all relevant status elements
public struct PlayerStatus {
    public var time = TimeStatus()
    public var currentSong = Song()
    public var quality = QualityStatus()
    public var volume = Float(0)
    public var playqueue = PlayqueueStatus()
    public var playing = PlayStatus()
    
    public init() {}
    
    public init(_ from: PlayerStatus) {
        time = from.time
        currentSong = from.currentSong
        quality = from.quality
        volume = from.volume
        playqueue = from.playqueue
        playing = from.playing
    }

}
extension PlayerStatus: CustomStringConvertible {
    public var description: String {
        return "> PlayerStatus\n" +
            "   \(time)" +
            "   \(currentSong)" +
            "   \(quality)" +
            "   \(playqueue)" +
            "   \(playing)" +
        "    volume = \(volume)\n"
    }
}
extension PlayerStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> PlayerStatus\n" +
            "   \(time)" +
            "   \(currentSong)" +
            "   \(quality)" +
            "   \(playqueue)" +
            "   \(playing)" +
        "    volume = \(volume)\n"
    }
}
