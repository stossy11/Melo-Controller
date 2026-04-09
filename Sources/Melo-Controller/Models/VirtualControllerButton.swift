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
    static let A = Self("A")
    static let B = Self("B")
    static let X = Self("X")
    static let Y = Self("Y")
    static let back = Self("back")
    static let guide = Self("guide")
    static let start = Self("start")
    static let leftStick = Self("leftStick")
    static let rightStick = Self("rightStick")
    static let leftShoulder = Self("leftShoulder")
    static let rightShoulder = Self("rightShoulder")
    static let dPadUp = Self("dPadUp")
    static let dPadDown = Self("dPadDown")
    static let dPadLeft = Self("dPadLeft")
    static let dPadRight = Self("dPadRight")
    static let leftTrigger = Self("leftTrigger")
    static let rightTrigger = Self("rightTrigger")
    
    static let defaultConfigs: [VirtualControllerButton: String] = [
        .A: "a.circle.fill",
        .B: "b.circle.fill",
        .X: "x.circle.fill",
        .Y: "y.circle.fill",
        .leftStick: "l.joystick.press.down.fill",
        .rightStick: "r.joystick.press.down.fill",
        .dPadUp: "arrowtriangle.up.circle.fill",
        .dPadDown: "arrowtriangle.down.circle.fill",
        .dPadLeft: "arrowtriangle.left.circle.fill",
        .dPadRight: "arrowtriangle.right.circle.fill",
        .leftTrigger: "zl.rectangle.roundedtop.fill",
        .rightTrigger: "zr.rectangle.roundedtop.fill",
        .leftShoulder: "l.rectangle.roundedbottom.fill",
        .rightShoulder: "r.rectangle.roundedbottom.fill",
        .start: "plus.circle.fill",
        .back: "minus.circle.fill",
        .guide: "gearshape.fill"
    ]

    static func registerDefaults() {
        let register = ButtonRegistry.shared.register
        for (button, icon) in defaultConfigs {
            register(button, .init(iconName: icon))
        }
    }
}
