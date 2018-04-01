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

public enum CoverURI {
    case fullPathURI(String)
    case filenameOptionsURI(String, [String])
    
    public var baseUri: String {
        get {
            switch self {
            case let .fullPathURI(uri):
                return uri
            case let .filenameOptionsURI(baseUri, _):
                return baseUri
            }
        }
    }
    
    public var possibleUris: [String] {
        get {
            switch self {
            case let .fullPathURI(uri):
                return [uri]
            case let .filenameOptionsURI(baseUri, possibleFilenames):
                return possibleFilenames.map({ (possibleFilename) -> String in
                    "\(baseUri)\(possibleFilename)"
                })
            }
        }
    }
}

extension CoverURI: Equatable {}
public func ==(lhs: CoverURI, rhs: CoverURI) -> Bool {
    switch (lhs, rhs) {
    case let (.fullPathURI(uriB), .fullPathURI(uriA)):
        return uriA == uriB
    case let (.filenameOptionsURI(baseUriA, possibleFilenamesA), .filenameOptionsURI(baseUriB, possibleFilenamesB)):
        return baseUriA == baseUriB && possibleFilenamesA == possibleFilenamesB
    default:
        return false
    }
}

extension CoverURI: Hashable {
    public var hashValue: Int {
        var concatUri = ""
        for possibleUri in possibleUris {
            concatUri.append(possibleUri)
        }
        return concatUri.hashValue
    }
}


