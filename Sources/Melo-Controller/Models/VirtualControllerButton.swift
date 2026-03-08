//
//  VirtualControllerButton.swift
//  Melo-Controller
//
//  Created by Stossy11 on 8/3/2026.
//

import Foundation

public enum VirtualControllerButton: Int, Codable {
    case A
    case B
    case X
    case Y
    case back
    case guide
    case start
    case leftStick
    case rightStick
    case leftShoulder
    case rightShoulder
    case dPadUp
    case dPadDown
    case dPadLeft
    case dPadRight
    case leftTrigger
    case rightTrigger
    
    public var isTrigger: Bool {
        switch self {
        case .leftTrigger, .rightTrigger, .leftShoulder, .rightShoulder:
            return true
        default:
            return false
        }
    }
    
    public var isDPad: Bool {
        switch self {
        case .dPadUp, .dPadDown, .dPadLeft, .dPadRight:
            return true
        default:
            return false
        }
    }
    
    public var isSmall: Bool {
        switch self {
        case .back, .start, .guide:
            return true
        default:
            return false
        }
    }
}
