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

/// A struct defining a generic Folder object.
public struct Folder {
    /// A unique id for the folder. Usage depends on library implementation.
    public var id = ""
    
    /// The source of this folder (i.e. the service like Spotify, LocalMusic etc).
    public var source = SourceType.Local
    
    /// The path of the folder.
    public var path = ""
    
    /// The name of the folder to display.
    public var name = ""
    
    public init() {
    }
    
    public init(id: String,
                source: SourceType,
                path: String,
                name: String) {
        self.id = id
        self.source = source
        self.path = path
        self.name = name
    }
}

extension Folder: Equatable {}
public func ==(lhs: Folder, rhs: Folder) -> Bool {
    return lhs.id == rhs.id && lhs.source == rhs.source
}

extension Folder: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

extension Folder: CustomStringConvertible {
    public var description: String {
        return "> Folder\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    path = \(path)\n" +
        "    name = \(name)\n"
    }
}

extension Folder: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "> Artist\n" +
            "    id = \(id)\n" +
            "    source = \(source)\n" +
            "    path = \(path)\n" +
        "    name = \(name)\n"
    }
}
