//
//  VirtualControllerButton.swift
//  Melo-Controller
//
//  Created by Stossy11 on 8/3/2026.
//

import Foundation

public struct VirtualContButtonConfig: Hashable, Codable, Identifiable {
    public var id = UUID.init()
    
    public var small: Bool = false
    public var trigger: Bool = false
}

public struct VirtualControllerButton: Hashable, Codable, Identifiable {
    static var registered: Set<VirtualControllerButton> = []
    
    public let id: String
    public var iconName: String
    public var small: Bool
    public var trigger: Bool
    
    public init(_ id: String, systemName: String, small: Bool? = nil, trigger: Bool? = nil) {
        self.id = id
        self.iconName = systemName
        self.small = small ?? false
        self.trigger = trigger ?? false
        
        Self.registered.insert(self)
    }
}

public extension VirtualControllerButton {
    var isTrigger: Bool {
        Self.registered.contains(where: { $0.id == id && $0.trigger })
    }
    
    var isDPad: Bool {
        ["dPadUp", "dPadDown", "dPadLeft", "dPadRight"].contains(id)
    }
    
    var isSmall: Bool {
        Self.registered.contains(where: { $0.id == id && $0.small })
    }
}

public extension VirtualControllerButton {
    static let A = Self("A", systemName: "a.circle.fill")
    static let B = Self("B", systemName: "a.circle.fill")
    static let X = Self("X", systemName: "a.circle.fill")
    static let Y = Self("Y", systemName: "a.circle.fill")
    static let back = Self("back", systemName: "a.circle.fill", small: true)
    static let guide = Self("guide", systemName: "a.circle.fill", small: true)
    static let start = Self("start", systemName: "a.circle.fill", small: true)
    static let leftStick = Self("leftStick", systemName: "a.circle.fill")
    static let rightStick = Self("rightStick", systemName: "a.circle.fill")
    static let leftShoulder = Self("leftShoulder", systemName: "a.circle.fill", trigger: true)
    static let rightShoulder = Self("rightShoulder", systemName: "a.circle.fill", trigger: true)
    static let dPadUp = Self("dPadUp", systemName: "a.circle.fill")
    static let dPadDown = Self("dPadDown", systemName: "a.circle.fill")
    static let dPadLeft = Self("dPadLeft", systemName: "a.circle.fill")
    static let dPadRight = Self("dPadRight", systemName: "a.circle.fill")
    static let leftTrigger = Self("leftTrigger", systemName: "a.circle.fill", trigger: true)
    static let rightTrigger = Self("rightTrigger", systemName: "a.circle.fill", trigger: true)
}
