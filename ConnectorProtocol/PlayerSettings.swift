//
//  PlayerSettings.swift
//  ConnectorProtocol_iOS
//
//  Created by Berrie Kremers on 27-03-18.
//  Copyright © 2018 Kaotemba Software. All rights reserved.
//

import Foundation

public enum PlayerSettingType {
    case string
    case selection
    case toggle
}

/// Base class for player specific settings.
public class PlayerSetting {
    public var id: String
    public var description: String
    public var type: PlayerSettingType
    
    public init(type: PlayerSettingType,
         id: String,
         description: String) {
        self.type = type
        self.id = id
        self.description = description
    }
}

/// A setting that holds a string value.
public class StringSetting: PlayerSetting {
    public var placeholder: String
    public var value: String
    
    public init(id: String, description: String, placeholder: String, value: String) {
        self.placeholder = placeholder
        self.value = value
        super.init(type: .string, id: id, description: description)
    }
}

/// A setting that holds a boolean (on/off) value.
public class ToggleSetting: PlayerSetting {
    public var value: Bool
    
    public init(id: String, description: String, value: Bool) {
        self.value = value
        super.init(type: .toggle, id: id, description: description)
    }
}

/// A setting that holds a single selection from a list of options.
public class SelectionSetting: PlayerSetting {
    public var items: [Int: String]
    public var value: Int
    
    public init(id: String, description: String, items: [Int: String], value: Int) {
        self.items = items
        self.value = value
        super.init(type: .selection, id: id, description: description)
    }
}
