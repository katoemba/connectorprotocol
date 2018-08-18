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

/// A struct defining a generic Genre object.
public struct Genre {
    /// A unique id for the genre. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this genre (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Unknown
    
    /// The name of the genre.
    public var name = ""
    
    /// Whether this genre has sub-genres
    public var hasSubGenres = false
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                name: String,
                hasSubGenres: Bool = false) {
        self.id = id
        self.source = source
        self.name = name
        self.hasSubGenres = hasSubGenres
    }
}

extension Genre: Equatable {}
public func ==(lhs: Genre, rhs: Genre) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source
}

extension Genre: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

extension Genre: CustomStringConvertible {
    public var description: String {
        return "> Genre\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    name = \(name)\n"
    }
}

extension Genre: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Genre\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    name = \(name)\n" +
        "    hasSubGenres = \(hasSubGenres)\n"
    }
}
