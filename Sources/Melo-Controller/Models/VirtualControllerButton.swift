//
//  VirtualControllerButton.swift
//  Melo-Controller
//
//  Created by Stossy11 on 8/3/2026.
//

import Foundation

public struct VirtualControllerButton: Hashable, Codable, Identifiable {
    public let id: String
    
    public init(_ id: String) {
        self.id = id
    }
    
    public init(_ id: String, systemName: String) {
        self.id = id
        
        ButtonRegistry.shared.register(self, config: .init(iconName: systemName))
    }
}

public extension VirtualControllerButton {
    var isTrigger: Bool {
        ["leftTrigger", "rightTrigger", "leftShoulder", "rightShoulder"].contains(id)
    }
    
    var isDPad: Bool {
        ["dPadUp", "dPadDown", "dPadLeft", "dPadRight"].contains(id)
    }
    
    var isSmall: Bool {
        ["back", "start", "guide"].contains(id)
    }
}

public extension VirtualControllerButton {
    static let A = Self("A", systemName: "a.circle.fill")
    static let B = Self("B", systemName: "a.circle.fill")
    static let X = Self("X", systemName: "a.circle.fill")
    static let Y = Self("Y", systemName: "a.circle.fill")
    static let back = Self("back", systemName: "a.circle.fill")
    static let guide = Self("guide", systemName: "a.circle.fill")
    static let start = Self("start", systemName: "a.circle.fill")
    static let leftStick = Self("leftStick", systemName: "a.circle.fill")
    static let rightStick = Self("rightStick", systemName: "a.circle.fill")
    static let leftShoulder = Self("leftShoulder", systemName: "a.circle.fill")
    static let rightShoulder = Self("rightShoulder", systemName: "a.circle.fill")
    static let dPadUp = Self("dPadUp", systemName: "a.circle.fill")
    static let dPadDown = Self("dPadDown", systemName: "a.circle.fill")
    static let dPadLeft = Self("dPadLeft", systemName: "a.circle.fill")
    static let dPadRight = Self("dPadRight", systemName: "a.circle.fill")
    static let leftTrigger = Self("leftTrigger", systemName: "a.circle.fill")
    static let rightTrigger = Self("rightTrigger", systemName: "a.circle.fill")
}
