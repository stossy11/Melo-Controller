//
//  ControllerButton.swift
//  Melo-Controller
//
//  Created by Stossy11 on 10/1/2026.
//

import UIKit
import SwiftUI

class ControllerUIButton: UIButton {
    private var isPressing = false
    
    var onPress: (() -> Void)?
    var onRelease: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = false
        
        addTarget(self, action: #selector(handlePress), for: .touchDown)
        addTarget(self, action: #selector(handleRelease), for: .touchUpInside)
        addTarget(self, action: #selector(handleRelease), for: .touchUpOutside)
        addTarget(self, action: #selector(handleRelease), for: .touchDragExit)
        addTarget(self, action: #selector(handleRelease), for: .touchCancel)
    }
    
    @objc private func handlePress() {
        guard !isPressing else { return }
        isPressing = true
        onPress?()
    }
    
    @objc private func handleRelease() {
        guard isPressing else { return }
        isPressing = false
        onRelease?()
    }
}

struct ControllerUIButtonViewRepresentable: UIViewRepresentable {
    let onPress: () -> Void
    let onRelease: () -> Void
    
    func makeUIView(context: Context) -> ControllerUIButton {
        let button = ControllerUIButton(frame: .zero)
        button.onPress = onPress
        button.onRelease = onRelease
        return button
    }
    
    func updateUIView(_ uiView: ControllerUIButton, context: Context) {
        uiView.onPress = onPress
        uiView.onRelease = onRelease
    }
}

