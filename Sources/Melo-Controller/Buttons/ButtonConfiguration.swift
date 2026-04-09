//
//  ButtonConfiguration.swift
//  Melo-Controller
//
//  Created by Stossy11 on 26/1/2026.
//

import SwiftUI

public struct ButtonConfiguration {
    public let iconName: String
    
    public init(iconName: String) {
        self.iconName = iconName
    }
}

public final class ButtonRegistry {
    public static var shared = ButtonRegistry()
    
    private var configs: [VirtualControllerButton: ButtonConfiguration] = [:]
    
    
    private init() {
        VirtualControllerButton.registerDefaults()
    }
    
    public func register(_ button: VirtualControllerButton, config: ButtonConfiguration) {
        configs[button] = config
    }
    
    public func deregister(_ button: VirtualControllerButton) {
        configs.removeValue(forKey: button)
    }
    
    public func deregisterDefaults() {
        for button in VirtualControllerButton.defaultConfigs.keys {
            configs.removeValue(forKey: button)
        }
    }
    
    public func deregisterAll() {
        configs.removeAll()
    }
    
    public func config(for button: VirtualControllerButton) -> ButtonConfiguration? {
        configs[button]
    }
}
