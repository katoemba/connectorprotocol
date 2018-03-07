//
//  HelpMePlease.swift
//  ConnectorProtocol_iOS
//
//  Copyright 2018 - Katoemba Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public class HelpMePlease {
    public static var logAllocations = false
    private static var allocCounter = [String: Int]()
    
    public static func allocUp(name: String) {
        if logAllocations {
            let count = allocCounter[name] ?? 0
            allocCounter[name] = count + 1
            print("allocUp(\(name)) -> \(count + 1)")
        }
    }
    public static func allocDown(name: String) {
        if logAllocations {
            let count = allocCounter[name] ?? 0
            allocCounter[name] = count - 1
            print("allocDown(\(name)) -> \(count - 1)")
        }
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

public extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    public func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
