//
//  HelpMePlease.swift
//  ConnectorProtocol_iOS
//
//  Created by Berrie Kremers on 05-01-18.
//  Copyright © 2018 Kaotemba Software. All rights reserved.
//

import Foundation

public class HelpMePlease {
    static var allocCounter = [String: Int]()
    public static func allocUp(name: String) {
        //let count = allocCounter[name] ?? 0
        //allocCounter[name] = count + 1
        //print("allocUp(\(name)) -> \(count + 1)")
    }
    public static func allocDown(name: String) {
        //let count = allocCounter[name] ?? 0
        //allocCounter[name] = count - 1
        //print("allocDown(\(name)) -> \(count - 1)")
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
