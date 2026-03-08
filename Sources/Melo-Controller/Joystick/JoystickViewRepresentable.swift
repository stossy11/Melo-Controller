//
//  JoystickViewRepresentable.swift
//  Melo-Controller
//
//  Created by Stossy11 on 28/2/2026.
//


import SwiftUI

struct JoystickViewRepresentable: UIViewRepresentable {
    var right: Bool
    var showBackground: Bool
    var controller: any Controller
    var mPosition: Bool = true
    
    init(controller: any Controller, right: Bool, showBackground: Bool = false) {
        self.right = right
        self.showBackground = showBackground
        self.controller = controller
        mPosition = false
    }
    
    func makeUIView(context: Context) -> JoystickView {
        let view = JoystickView()
        view.right = right
        view.background = showBackground
        
        if mPosition {
            view.onPositionChanged = { newPosition in
                DispatchQueue.main.async {
                    controller.joystickMoved(position: newPosition, right: right)
                }
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: JoystickView, context: Context) {}
}
