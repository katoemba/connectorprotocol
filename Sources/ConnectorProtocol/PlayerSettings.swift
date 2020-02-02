//
//  PlayerSettings.swift
//  ConnectorProtocol_iOS
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

public enum PlayerSettingType {
    case string
    case selection
    case toggle
    case action
    case dynamic
}

public enum StringSettingRestriction {
    case readonly
    case regular
    case password
    case numeric
    case email
}

public typealias ValidationFunction = (PlayerSetting, Any?) -> String?

/// Base class for player specific settings.
public class PlayerSetting {
    public var id: String
    public var description: String
    public var type: PlayerSettingType
    public var validation: ValidationFunction?

    
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
    public var restriction: StringSettingRestriction
    
    public init(id: String, description: String, placeholder: String, value: String, restriction: StringSettingRestriction = .regular) {
        self.placeholder = placeholder
        self.value = value
        self.restriction = restriction
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

/// A setting that holds a single selection from a list of options.
public class ActionSetting: PlayerSetting {
    public var action: () -> Observable<String>

    public init(id: String, description: String, action: @escaping () -> Observable<String>) {
        self.action = action
        super.init(type: .action, id: id, description: description)
    }
}

/// A setting that holds a single selection from a list of options.
public class DynamicSetting: PlayerSetting {
    public var titleObservable: Observable<String>
    
    public init(id: String, description: String, titleObservable: Observable<String>) {
        self.titleObservable = titleObservable
        super.init(type: .dynamic, id: id, description: description)
    }
}

public class PlayerSettingGroup {
    public var title: String
    public var description: String
    public var settings: [PlayerSetting]
    
    public init(title: String, description: String, settings: [PlayerSetting]) {
        self.title = title
        self.description = description
        self.settings = settings
    }
}
