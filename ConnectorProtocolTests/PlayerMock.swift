//
//  PlayerMock.swift
//  ConnectorProtocol
//
//  Created by Berrie Kremers on 11-08-17.
//  Copyright © 2017 Kaotemba Software. All rights reserved.
//

import Foundation
import ConnectorProtocol

class PlayerMock: MockBase, PlayerProtocol {
    var uniqueID = "ID1"
    var connectionStatus = ConnectionStatus.Connected

    var connectionProperties: [String: Any] {
        return ["ip": "1.1.1.1", "port": 80]
    }
    
    func connect(numberOfTries: Int = 1) {
        registerCall("connect", [:])
    }
}
