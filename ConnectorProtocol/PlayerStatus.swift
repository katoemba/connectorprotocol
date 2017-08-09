//
//  PlayerStatus.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 05-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation

public enum PlayStatus {
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

/// A class holding the current status of a player. PlayerStatusChangeNotification will be sent out when any of the values change.
public class PlayerStatus {
    /// Private dictionary to hold a set of notifications to be sent after an update cycle is finished.
    private var _changeNotifications: [PlayerStatusChangeNotification: Int] = [:]
    
    /// Initializer function.
    public init() {
    }
    
    /// The current playing status of a player.
    /// When changed a notification PlayerStatusChangeNotification.PlayingStatus will be sent.
    public var playingStatus = PlayStatus.Paused {
        didSet {
            if playingStatus != oldValue {
                _changeNotifications[.PlayingStatus] = 1
            }
        }
    }
    
    /// The current volume at which a player is playing. Contains a value between 0.0 and 1.0.
    /// When changed a notification PlayerStatusChangeNotification.Volume will be sent.
    public var volume = Float(0.0) {
        didSet {
            if volume != oldValue {
                _changeNotifications[.Volume] = 1
            }
        }
    }
    
    /// The currently active repeat mode of a player.
    /// When changed a notification PlayerStatusChangeNotification.RepeatMode will be sent.
    public var repeatMode = RepeatMode.Off {
        didSet {
            if repeatMode != oldValue {
                _changeNotifications[.RepeatMode] = 1
            }
        }
    }
    
    /// The currently active shuffle mode of a player.
    /// When changed a notification PlayerStatusChangeNotification.ShuffleMode will be sent.
    public var shuffleMode = ShuffleMode.Off {
        didSet {
            if shuffleMode != oldValue {
                _changeNotifications[.ShuffleMode] = 1
            }
        }
    }
    
    /// The index (position) of the currently playing song in the playqueue.
    /// When changed a notification PlayerStatusChangeNotification.SongInfo will be sent.
    public var songIndex = 0 {
        didSet {
            if songIndex != oldValue {
                _changeNotifications[.SongInfo] = 1
            }
        }
    }
    
    /// A unique identifier for the currently playing song. Implementation is depending on the library implementation.
    /// When changed a notification PlayerStatusChangeNotification.SongInfo will be sent.
    public var songID = "" {
        didSet {
            if songID != oldValue {
                _changeNotifications[.SongInfo] = 1
            }
        }
    }
    
    /// The name of the artist(s) that perform the currently playing song.
    /// When changed a notification PlayerStatusChangeNotification.SongInfo will be sent.
    public var artist = "" {
        didSet {
            if artist != oldValue {
                _changeNotifications[.SongInfo] = 1
            }
        }
    }
    
    /// The title of the album on which the currently playing song appears.
    /// When changed a notification PlayerStatusChangeNotification.SongInfo will be sent.
    public var album = "" {
        didSet {
            if album != oldValue {
                _changeNotifications[.SongInfo] = 1
            }
        }
    }

    /// The title of the currently playing song.
    /// When changed a notification PlayerStatusChangeNotification.SongInfo will be sent.
    public var song = "" {
        didSet {
            if song != oldValue {
                _changeNotifications[.SongInfo] = 1
            }
        }
    }
    
    /// The name of the currently playing station. Empty in case not playing a station.
    /// When changed a notification PlayerStatusChangeNotification.StationInfo will be sent.
    public var station = "" {
        didSet {
            if station != oldValue {
                _changeNotifications[.StationInfo] = 1
            }
        }
    }

    /// The duration of the currently playing song in seconds.
    /// When changed a notification PlayerStatusChangeNotification.TrackTime will be sent.
    public var trackTime = 0 {
        didSet {
            if trackTime != oldValue {
                _changeNotifications[.TrackTime] = 1
            }
        }
    }
    
    /// The elapsed time within the currently playing song in seconds.
    /// When changed a notification PlayerStatusChangeNotification.TrackTime will be sent.
    public var elapsedTime = 0 {
        didSet {
            if elapsedTime != oldValue {
                _changeNotifications[.TrackTime] = 1
            }
        }
    }
    
    /// A string describing the bitrate of the currently playing song.
    /// When changed a notification PlayerStatusChangeNotification.Quality will be sent.
    public var bitrate = "" {
        didSet {
            if bitrate != oldValue {
                _changeNotifications[.Quality] = 1
            }
        }
    }
    
    /// A string describing the encoding of the currently playing song.
    /// When changed a notification PlayerStatusChangeNotification.Quality will be sent.
    public var encoding = "" {
        didSet {
            if encoding != oldValue {
                _changeNotifications[.Quality] = 1
            }
        }
    }
    
    /// Start an update cycle of a PlayerStatus object. This will start collection update notifications.
    public func beginUpdate() {
        _changeNotifications = [:]
    }
    
    /// Complete an update cycle of a PlayerStatus object. This will send out any collected notifications.
    public func endUpdate() {
        for notificationKey in _changeNotifications.keys {
            let notification = Notification.init(name: NSNotification.Name.init(notificationKey.rawValue), object: nil, userInfo: ["status": self])
            NotificationCenter.default.post(notification)
        }
        _changeNotifications = [:]
    }
}

extension PlayerStatus: CustomStringConvertible {
    public var description: String {
        return "> PlayerStatus\n" +
        "    playingStatus = \(playingStatus)\n" +
        "    volume = \(volume)\n" +
        "    repeatMode = \(repeatMode)\n" +
        "    shuffleMode = \(shuffleMode)\n" +
        "    songIndex = \(songIndex)\n" +
        "    songID = \(songID)\n" +
        "    artist = \(artist)\n" +
        "    album = \(album)\n" +
        "    song = \(song)\n" +
        "    station = \(station)\n" +
        "    trackTime = \(trackTime)\n" +
        "    elapsedTime = \(elapsedTime)\n" +
        "    bitrate = \(bitrate)\n" +
        "    encoding = \(encoding)\n"
    }
}

extension PlayerStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> PlayerStatus\n" +
            "    playingStatus = \(playingStatus)\n" +
            "    volume = \(volume)\n" +
            "    repeatMode = \(repeatMode)\n" +
            "    shuffleMode = \(shuffleMode)\n" +
            "    songIndex = \(songIndex)\n" +
            "    songID = \(songID)\n" +
            "    artist = \(artist)\n" +
            "    album = \(album)\n" +
            "    song = \(song)\n" +
            "    station = \(station)\n" +
            "    trackTime = \(trackTime)\n" +
            "    elapsedTime = \(elapsedTime)\n" +
            "    bitrate = \(bitrate)\n" +
        "    encoding = \(encoding)\n"
    }
}
