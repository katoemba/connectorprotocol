//
//  PlayerStatus.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public enum PlayPauseMode {
    case Paused
    case Playing
    case Stopped
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

public enum PlayerStatusChangeNotification: String {
    case PlayingStatus = "PlayerStatusChangePlayingStatus"
    case Volume = "PlayerStatusChangeVolume"
    case RepeatMode = "PlayerStatusChangeRepeatMode"
    case ShuffleMode = "PlayerStatusChangeShuffleMode"
    case SongInfo = "PlayerStatusChangeSongInfo"
    case StationInfo = "PlayerStatusChangeStationInfo"
    case TrackTime = "PlayerStatusChangeTrackTime"
    case Quality = "PlayerStatusChangeQuality"
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
    public var shuffleMode = ShuffleMode.Off
    public var repeatMode = RepeatMode.Off
}
extension PlayStatus: Equatable {}
public func ==(lhs: PlayStatus, rhs: PlayStatus) -> Bool {
    return lhs.playPauseMode == rhs.playPauseMode &&
        lhs.shuffleMode == rhs.shuffleMode &&
        lhs.repeatMode == rhs.repeatMode
}
extension PlayStatus: CustomStringConvertible {
    public var description: String {
        return "> PlayStatus\n" +
            "    playingStatus = \(playPauseMode)\n" +
            "    repeatMode = \(repeatMode)\n" +
        "    shuffleMode = \(shuffleMode)\n"
    }
}
extension PlayStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> PlayStatus\n" +
            "    playingStatus = \(playPauseMode)\n" +
            "    repeatMode = \(repeatMode)\n" +
        "    shuffleMode = \(shuffleMode)\n"
    }
}

/// A PlayerStatus class where all elements are exposed as Drivers.
/// Elements are logically grouped so that subscriptions can be made to individual areas of interest.
public class ObservablePlayerStatus {
    private var _time = Variable<TimeStatus>(TimeStatus())
    public var time: Driver<TimeStatus> {
        get {
            return _time.asDriver()
        }
    }
    
    private var _currentSong = Variable<Song>(Song())
    public var currentSong: Driver<Song> {
        get {
            return _currentSong.asDriver()
        }
    }
    
    private var _quality = Variable<QualityStatus>(QualityStatus())
    public var quality: Driver<QualityStatus> {
        get {
            return _quality.asDriver()
        }
    }

    public var _volume = Variable<Float>(0)
    public var volume: Driver<Float> {
        get {
            return _volume.asDriver()
        }
    }

    public var _playqueue = Variable<PlayqueueStatus>(PlayqueueStatus())
    public var playqueue: Driver<PlayqueueStatus> {
        get {
            return _playqueue.asDriver()
        }
    }

    public var _playing = Variable<PlayStatus>(PlayStatus())
    public var playing: Driver<PlayStatus> {
        get {
            return _playing.asDriver()
        }
    }

    public init() {}
    
    public func set(playerStatus: PlayerStatus) {
        _time.value = playerStatus.time
        _currentSong.value = playerStatus.currentSong
        _quality.value = playerStatus.quality
        _volume.value = playerStatus.volume
        _playqueue.value = playerStatus.playqueue
        _playing.value = playerStatus.playing
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
