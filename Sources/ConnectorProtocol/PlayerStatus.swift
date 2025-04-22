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

public enum ConsumeMode {
    case Off
    case On
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
    
    fileprivate func elapsedTime(_ elapsedTime: Int) -> TimeStatus {
        var copy = self
        copy.elapsedTime = elapsedTime
        return copy
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

public struct QualityStatus: Codable, Sendable {
    public enum QualityIndicator: Sendable {
        case regular
        case cd
        case hd
    }
    
    public enum RawEncoding: Codable {
        case bits(UInt32)
        case text(String)
    }
    public var bitrate: String {
        guard let rawBitrate = rawBitrate, rawBitrate > 0 else { return "" }
        return "\(rawBitrate / 1000) kbps"
    }
    public var samplerate: String {
        if let rawSamplerate = rawSamplerate {
            return "\(String(format: "%.1f", Double(rawSamplerate) / 1000.0)) kHz"
        }
        switch rawEncoding {
        case let .text(encodingString):
            if encodingString == "DSD64" {
                return "2822.4 kHz"
            }
            if encodingString == "DSD128" {
                return "5644.8 kHz"
            }
            if encodingString == "DSD256" {
                return "11289.6 kHz"
            }
            if encodingString == "DSD512" {
                return "22579.2 kHz"
            }
            if encodingString == "DSD1024" {
                return "45185.4 kHz"
            }
        default:
            break
        }
        
        return ""
    }
    
    public var encoding: String {
        guard let rawEncoding = rawEncoding else { return "" }
        switch rawEncoding {
        case let .text(text):
            return text
        case let .bits(bits):
            return "\(bits) bits"
        }
    }
    public var channels: String {
        guard let rawChannels = rawChannels, rawChannels > 0 else { return "" }
        return "\(rawChannels)"
    }
    public var uiDescription: String {
        var descr = ""
        var separator = ""
        if filetype != "" {
            descr += separator + filetype
            separator = " - "
        }
        if bitrate != "" {
            descr += separator + bitrate
            separator = " - "
        }
        if encoding != "" {
            descr += separator + encoding
            separator = " - "
        }
        if samplerate != "" {
            descr += separator + samplerate
            separator = " - "
        }
        
        return descr
    }
    
    public var qualityIndicator: QualityIndicator {
        if case let .text(text) = rawEncoding {
            if text.uppercased().starts(with: "DSD") {
                return .hd
            }
            if text.uppercased().starts(with: "Float") && ["M4A"].contains(filetype.uppercased()) == false && rawSamplerate ?? 0 > 44000 {
                return .hd
            }
        }
        else if ["DSF", "DSD", "DFF"].contains(filetype.uppercased()) {
            return .hd
        }
        else if case let .bits(bits) = rawEncoding,
                ["FLAC", "ALAC", "AIFF", "WAV"].contains(filetype.uppercased()) {
            if bits >= 24 && (rawSamplerate ?? 0) >= 44000 {
                return .hd
            }
            else if bits >= 16 && (rawSamplerate ?? 0) >= 96000 {
                return .hd
            }
            else if bits >= 16 && (rawSamplerate ?? 0) >= 44000 {
                return .cd
            }
        }
        return .regular
    }
    
    public var rawBitrate: UInt32?
    public var rawSamplerate: UInt32?
    public var rawChannels: UInt32?
    public var rawEncoding: RawEncoding?
    public var filetype = ""

    public init(bitrate: String = "", samplerate: String = "", encoding: String = "", channels: String = "", filetype: String = "") {
        if bitrate != "" {
            if let rawBitrate = Double(bitrate.lowercased().replacingOccurrences(of: "kbps", with: "").replacingOccurrences(of: " ", with: "")) {
                self.rawBitrate = rawBitrate < 24000 ? UInt32(rawBitrate * 1000) : UInt32(rawBitrate)
            }
        }
        if samplerate != "" {
            if let rawSamplerate = Double(samplerate.lowercased().replacingOccurrences(of: "khz", with: "").replacingOccurrences(of: " ", with: "")) {
                self.rawSamplerate = rawSamplerate < 1000 ? UInt32(rawSamplerate * 1000) : UInt32(rawSamplerate)
            }
        }
        if channels != "" {
            rawChannels = UInt32(channels)
        }
        if encoding != "" {
            if let bits = UInt32(encoding.lowercased().replacingOccurrences(of: "bits", with: "").replacingOccurrences(of: " ", with: "")) {
                rawEncoding = .bits(bits)
            }
            else {
                rawEncoding = .text(encoding)
            }
        }
        self.filetype = filetype
    }
    
    public init(rawBitrate: UInt32? = nil, rawSamplerate: UInt32? = nil, rawChannels: UInt32?, rawEncoding: RawEncoding?, filetype: String = "") {
        if let rawBitrate = rawBitrate {
            self.rawBitrate = rawBitrate < 24000 ? rawBitrate * 1000 : rawBitrate
        }
        if let rawSamplerate = rawSamplerate {
            self.rawSamplerate = rawSamplerate < 1000 ? rawSamplerate * 1000 : rawSamplerate
        }
        self.rawChannels = rawChannels
        self.rawEncoding = rawEncoding
        self.filetype = filetype
    }

    public init(rawBitrate: UInt32? = nil, rawSamplerate: UInt32? = nil, rawChannels: UInt32?, encodingString: String, filetype: String = "") {
        if let rawBitrate = rawBitrate {
            self.rawBitrate = rawBitrate < 24000 ? rawBitrate * 1000 : rawBitrate
        }
        if let rawSamplerate = rawSamplerate {
            if rawSamplerate < 1000 {
                self.rawSamplerate = rawSamplerate * 1000
            }
            else {
                self.rawSamplerate = rawSamplerate
            }
        }
        self.rawChannels = rawChannels
        if encodingString != "" {
            if let bits = UInt32(encodingString.lowercased().replacingOccurrences(of: "bits", with: "").replacingOccurrences(of: " ", with: "")) {
                rawEncoding = .bits(bits)
            }
            else {
                rawEncoding = .text(encodingString)
            }
        }
        self.filetype = filetype
    }

    public init(_ from: QualityStatus) {
        rawBitrate = from.rawBitrate
        rawSamplerate = from.rawSamplerate
        rawChannels = from.rawChannels
        rawEncoding = from.rawEncoding
        filetype = from.filetype
    }
}
extension QualityStatus: Equatable {}
public func ==(lhs: QualityStatus, rhs: QualityStatus) -> Bool {
    return lhs.bitrate == rhs.bitrate &&
        lhs.samplerate == rhs.samplerate &&
        lhs.encoding == rhs.encoding &&
        lhs.channels == rhs.channels &&
        lhs.filetype == rhs.filetype
}
extension QualityStatus: CustomStringConvertible {
    public var description: String {
        return "> QualityStatus\n" +
            "    bitrate = \(bitrate)\n" +
            "    samplerate = \(samplerate)\n" +
            "    encoding = \(encoding)\n" +
            "    channels = \(channels)\n" +
        "    filetype = \(filetype)\n"
    }
}
extension QualityStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> QualityStatus\n" +
            "    bitrate = \(bitrate)\n" +
            "    samplerate = \(samplerate)\n" +
            "    encoding = \(encoding)\n" +
            "    channels = \(channels)\n" +
        "    filetype = \(filetype)\n"
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
    public var consumeMode = ConsumeMode.Off

    public init() {
    }

    public init(_ from: PlayStatus) {
        playPauseMode = from.playPauseMode
        randomMode = from.randomMode
        repeatMode = from.repeatMode
        consumeMode = from.consumeMode
    }
    
    fileprivate func playPauseMode(_ playMode: PlayPauseMode) -> PlayStatus {
        var copy = self
        copy.playPauseMode = playPauseMode
        return copy
    }
    
    fileprivate func randomMode(_ randomMode: RandomMode) -> PlayStatus {
        var copy = self
        copy.randomMode = randomMode
        return copy
    }
    
    fileprivate func repeatMode(_ repeatMode: RepeatMode) -> PlayStatus {
        var copy = self
        copy.repeatMode = repeatMode
        return copy
    }

    fileprivate func consumeMode(_ consumeMode: ConsumeMode) -> PlayStatus {
        var copy = self
        copy.consumeMode = consumeMode
        return copy
    }
}
extension PlayStatus: Equatable {}
public func ==(lhs: PlayStatus, rhs: PlayStatus) -> Bool {
    return lhs.playPauseMode == rhs.playPauseMode &&
        lhs.randomMode == rhs.randomMode &&
        lhs.repeatMode == rhs.repeatMode &&
        lhs.consumeMode == rhs.consumeMode
}
extension PlayStatus: CustomStringConvertible {
    public var description: String {
        return "> PlayStatus\n" +
            "    playingStatus = \(playPauseMode)\n" +
            "    repeatMode = \(repeatMode)\n" +
            "    randomMode = \(randomMode)\n" +
        "    consumeMode = \(consumeMode)\n"
    }
}
extension PlayStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> PlayStatus\n" +
            "    playingStatus = \(playPauseMode)\n" +
            "    repeatMode = \(repeatMode)\n" +
            "    randomMode = \(randomMode)\n" +
        "    consumeMode = \(consumeMode)\n"
    }
}

// MARK: - Output Struct

public struct Output {
    /// A unique id for the output. Usage depends on library implementation.
    public var id = ""
    
    /// The name of the output.
    public var name = ""
    
    /// Whether or not this output is currently enabled.
    public var enabled = true
    
    public init() {
        
    }

    public init(_ from: Output) {
        id = from.id
        name = from.name
        enabled = from.enabled
    }    
}
extension Output: Equatable {}
public func ==(lhs: Output, rhs: Output) -> Bool {
    return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.enabled == rhs.enabled
}
extension Output: CustomStringConvertible {
    public var description: String {
        return "> Output\n" +
            "    id = \(id)\n" +
            "    name = \(name)\n" +
        "    enabled = \(enabled)\n"
    }
}
extension Output: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Output\n" +
            "    id = \(id)\n" +
            "    name = \(name)\n" +
        "    enabled = \(enabled)\n"
    }
}


/// A PlayerStatus object containing all relevant status elements
public struct PlayerStatus {
    public var lastUpdateTime = Date(timeIntervalSince1970: 0)
    public var time = TimeStatus()
    public var currentSong = Song()
    public var quality = QualityStatus()
    public var volume = Float(0)
    public var volumeEnabled = true
    public var playqueue = PlayqueueStatus()
    public var playing = PlayStatus()
    public var outputs = [Output]()
    
    public init() {}
    
    public init(_ from: PlayerStatus) {
        lastUpdateTime = from.lastUpdateTime
        time = from.time
        currentSong = from.currentSong
        quality = from.quality
        volume = from.volume
        volumeEnabled = from.volumeEnabled
        playqueue = from.playqueue
        playing = from.playing
        outputs = from.outputs
    }
    
    public func playPauseMode(_ playPauseMode: PlayPauseMode) -> PlayerStatus {
        var copy = self
        copy.playing = playing.playPauseMode(playPauseMode)
        return copy
    }

    public func repeatMode(_ repeatMode: RepeatMode) -> PlayerStatus {
        var copy = self
        copy.playing = playing.repeatMode(repeatMode)
        return copy
    }

    public func randomMode(_ randomMode: RandomMode) -> PlayerStatus {
        var copy = self
        copy.playing = playing.randomMode(randomMode)
        return copy
    }

    public func consumeMode(_ consumeMode: ConsumeMode) -> PlayerStatus {
        var copy = self
        copy.playing = playing.consumeMode(consumeMode)
        return copy
    }
    
    public func volume(_ volume: Float) -> PlayerStatus {
        var copy = self
        copy.volume = volume
        return copy
    }
    
    public func volumeEnabled(_ volumeEnabled: Bool) -> PlayerStatus {
        var copy = self
        copy.volumeEnabled = volumeEnabled
        return copy
    }
    
    public func elapsedTime(_ elapsedTime: Int) -> PlayerStatus {
        var copy = self
        copy.time = time.elapsedTime(elapsedTime)
        return copy
    }
}

extension PlayerStatus: Equatable {}
public func ==(lhs: PlayerStatus, rhs: PlayerStatus) -> Bool {
    return lhs.outputs == rhs.outputs &&
        lhs.playing == rhs.playing &&
        lhs.playqueue == rhs.playqueue &&
        lhs.quality == rhs.quality &&
        lhs.volume == rhs.volume &&
        lhs.volumeEnabled == rhs.volumeEnabled &&
        lhs.currentSong == rhs.currentSong &&
        lhs.time == rhs.time
}

extension PlayerStatus: CustomStringConvertible {
    public var description: String {
        return "> PlayerStatus\n" +
            "   \(lastUpdateTime)" +
            "   \(time)" +
            "   \(currentSong)" +
            "   \(quality)" +
            "   \(playqueue)" +
            "   \(playing)" +
            "   volumeEnabled = \(volumeEnabled)" +
            "   volume = \(volume)\n"
    }
}
extension PlayerStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> PlayerStatus\n" +
            "   \(lastUpdateTime)" +
            "   \(time)" +
            "   \(currentSong)" +
            "   \(quality)" +
            "   \(playqueue)" +
            "   \(playing)" +
            "   volumeEnabled = \(volumeEnabled)" +
            "   volume = \(volume)\n" +
            "   outputs = \(outputs.debugDescription)"
    }
}
