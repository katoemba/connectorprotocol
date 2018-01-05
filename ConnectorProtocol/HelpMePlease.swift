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
