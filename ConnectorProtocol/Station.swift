//
// ConnectorProtocol
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

/// A struct defining a generic Album object.
public struct Station {
    /// A unique id for the station. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this song (i.e. a service like TuneIn).
    public var source = SourceType.Unknown
    
    /// The url of the station.
    public var url = ""

    /// The name of the station.
    public var title = ""
    
    /// A description of the station.
    public var descr = ""
    
    /// The track that is currently playing on the station.
    public var nowPlaying = ""
    
    /// The name of the genre that is served by the station.
    public var genre = [] as [String]
    
    /// URI through which station artwork can be fetched.
    public var stationArtwork = ""
    
    /// The quality in which the station is broadcasting.
    public var bitrate = Int(0)
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                url: String,
                title: String,
                descr: String,
                nowPlaying: String,
                genre: [String],
                stationArtwork: String,
                bitrate: Int) {
        self.id = id
        self.source = source
        self.url = url
        self.title = title
        self.descr = descr
        self.nowPlaying = nowPlaying
        self.genre = genre
        self.stationArtwork = stationArtwork
        self.bitrate = bitrate
    }
}

extension Station: Equatable {}
public func ==(lhs: Station, rhs: Station) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source
}

extension Station: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

extension Station: CustomStringConvertible {
    public var description: String {
        return "> Station\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    title = \(title)\n" +
            "    url = \(url)\n"
    }
}

extension Station: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Station\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    title = \(title)\n" +
            "    url = \(url)\n" +
            "    descr = \(descr)\n" +
            "    nowPlaying = \(nowPlaying)\n" +
            "    genre = \(genre)\n" +
            "    stationArtwork = \(stationArtwork)\n" +
            "    bitrate = \(bitrate)\n"
    }
}
