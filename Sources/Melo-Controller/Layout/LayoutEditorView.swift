//
//  LayoutEditorView.swift
//  Melo-Controller
//
//  Created by Stossy11 on 26/1/2026.
//

import SwiftUI

class JoystickDPadUIHandler: ObservableObject {
    @Published var gameId: String?
    
    var joystickDpad: Bool {
        get {
            UserDefaults.standard.bool(forKey: "joystickDpad-\(gameId ?? "global")")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "joystickDpad-\(gameId ?? "global")")
            objectWillChange.send()
        }
    }
}

struct LayoutEditorView: View {
    @AppStorage("On-ScreenControllerScale") private var controllerScale: Double = 1.0
    @AppStorage("stickButton") private var stickButton = false
    @AppStorage("buttonSlide") private var buttonSlide = true
    @StateObject var joystickDpad = JoystickDPadUIHandler()
    
    @Binding var hideDpad: Bool
    @Binding var hideABXY: Bool
    @Binding var isEditing: Bool
    @Binding var showEditControls: Bool
    @Binding var layout: LayoutConfig
    
    @State private var selectedButton: String?
    @State private var selectedJoystick: String?
    @State private var showingLayoutOptions = false
    @State private var showingResetAlert = false
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.dismiss) var dismiss
    
    var gameId: String?
    
    private var isWide: Bool { verticalSizeClass == .compact || UIDevice.current.userInterfaceIdiom == .pad }
    
    private var selectionKey: String {
        "\(selectedButton ?? "-")|\(selectedJoystick ?? "-")"
    }
    
    private func syncDpadHandler() {
        joystickDpad.gameId = gameId
    }
    
    private func saveLayout() {
        LayoutManager.shared.save(layout, for: gameId)
    }
    
    private func clearSelection() {
        selectedButton = nil
        selectedJoystick = nil
    }
    
    var body: some View {
        VStack(spacing: 10) {
            toolbar
            
            HStack(alignment: .top, spacing: 10) {
                inspector
                    .frame(maxWidth: 380, alignment: .leading)
                
                Spacer(minLength: 0)
                
                if let gameId = gameId {
                    gameBadge(gameId)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: selectionKey)
        .onAppear {
            syncDpadHandler()
        }
        .onChange(of: gameId) { _ in
            syncDpadHandler()
        }
        .sheet(isPresented: $showingLayoutOptions) {
            LayoutOptionsView(gameId: gameId, layout: $layout)
        }
        .alert("Reset This Layout?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                layout = LayoutConfig()
                LayoutManager.shared.reset(for: gameId)
                clearSelection()
            }
        } message: {
            Text("Every button and stick goes back to its default position, size and options.")
        }
    }
    
    private var toolbar: some View {
        HStack(spacing: 8) {
            if isWide {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2")
                    Text("Edit Layout")
                        .fontWeight(.semibold)
                }
                .font(.footnote)
                .foregroundColor(.primary)
                .padding(.leading, 4)
                .padding(.trailing, 2)
            }
            
            EditorChip(icon: "eye.slash", title: "Hide", tint: .secondary, showTitle: isWide) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showEditControls = false
                }
            }
            
            EditorChip(icon: "slider.horizontal.3", title: "Options", tint: .blue, showTitle: isWide) {
                showingLayoutOptions = true
            }
            
            EditorChip(icon: "arrow.counterclockwise", title: "Reset All", tint: .orange, showTitle: isWide) {
                showingResetAlert = true
            }
            
            Spacer(minLength: 4)
            
            Button {
                saveLayout()
                clearSelection()
                isEditing = false
                dismiss()
            } label: {
                Text("Done")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.accentColor))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.clear)
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
    }
    
    private func gameBadge(_ gameId: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "gamecontroller.fill")
                .foregroundColor(.blue)
            Text(gameId)
                .lineLimit(1)
                .truncationMode(.middle)
            if LayoutManager.shared.hasCustomLayout(for: gameId) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: 220)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    
    @ViewBuilder
    private var inspector: some View {
        if let selectedButton = selectedButton {
            buttonControls(for: selectedButton)
                .transition(.move(edge: .leading).combined(with: .opacity))
        } else if let selectedJoystick = selectedJoystick {
            joystickControls(for: selectedJoystick)
                .transition(.move(edge: .leading).combined(with: .opacity))
        } else {
            globalControls
                .transition(.opacity)
        }
    }
    
    private var globalControls: some View {
        EditorCard {
            EditorCardHeader(
                icon: "hand.tap",
                title: "Whole Controller",
                subtitle: "Tap a button or stick to edit it, drag it to move it.",
                tint: .accentColor
            )
            
            EditorDivider()
            
            EditorSliderRow(
                title: "Controller Size",
                value: Binding(get: { CGFloat(controllerScale) }, set: { controllerScale = Double($0) }),
                range: 0.5...2.0,
                tint: .accentColor
            )
            
            EditorToggleRow(
                icon: "hand.draw",
                title: "Roll Between Buttons",
                subtitle: "Slide a finger straight from one button to the next.",
                isOn: $buttonSlide,
                tint: .accentColor
            )
        }
    }
    
    
    private func buttonControls(for buttonId: String) -> some View {
        EditorCard {
            EditorCardHeader(
                icon: LayoutEditorNaming.icon(for: buttonId),
                title: LayoutEditorNaming.displayName(for: buttonId),
                subtitle: "Button",
                tint: .blue
            ) {
                EditorResetButton {
                    layout.buttons[buttonId] = nil
                    selectedButton = nil
                }
            }
            
            EditorDivider()
            
            EditorSliderRow(
                title: "Size",
                value: Binding(
                    get: { layout.buttons[buttonId]?.scale ?? 1.0 },
                    set: { layout.buttons[buttonId, default: ButtonLayout()].scale = $0 }
                ),
                range: 0.5...2.0,
                tint: .blue
            )
            
            EditorToggleRow(
                icon: "eye.slash",
                title: "Hide Button",
                isOn: Binding(
                    get: { layout.buttons[buttonId]?.hidden ?? false },
                    set: { layout.buttons[buttonId, default: ButtonLayout()].hidden = $0 }
                ),
                tint: .blue
            )
            
            EditorToggleRow(
                icon: "pin",
                title: "Toggle Instead of Hold",
                subtitle: "Stays held down until it's tapped again.",
                isOn: Binding(
                    get: { layout.buttons[buttonId]?.toggle ?? false },
                    set: { layout.buttons[buttonId, default: ButtonLayout()].toggle = $0 }
                ),
                tint: .blue
            )
            
            if buttonId.lowercased().contains("dpad") {
                EditorToggleRow(
                    icon: "l.joystick",
                    title: "D-Pad Acts Like a Stick",
                    isOn: Binding(
                        get: { joystickDpad.joystickDpad },
                        set: { joystickDpad.joystickDpad = $0 }
                    ),
                    tint: .blue
                )
            }
        }
    }
    
    
    private func joystickControls(for joystickId: String) -> some View {
        EditorCard {
            EditorCardHeader(
                icon: joystickId.lowercased().hasPrefix("right") ? "r.joystick" : "l.joystick",
                title: LayoutEditorNaming.displayName(for: joystickId),
                subtitle: "Stick",
                tint: .green
            ) {
                EditorResetButton {
                    layout.joysticks[joystickId] = nil
                    selectedJoystick = nil
                }
            }
            
            EditorDivider()
            
            EditorSliderRow(
                title: "Size",
                value: Binding(
                    get: { layout.joysticks[joystickId]?.scale ?? 1.0 },
                    set: { layout.joysticks[joystickId, default: JoystickLayout()].scale = $0 }
                ),
                range: 0.5...2.0,
                tint: .green
            )
            
            EditorToggleRow(
                icon: "eye.slash",
                title: "Hide Stick",
                isOn: Binding(
                    get: { layout.joysticks[joystickId]?.hidden ?? false },
                    set: { layout.joysticks[joystickId, default: JoystickLayout()].hidden = $0 }
                ),
                tint: .green
            )
            
            EditorToggleRow(
                icon: "rectangle.on.rectangle.slash",
                title: "Hide Buttons Underneath",
                subtitle: "Fades the overlapping D-Pad or ABXY buttons while the stick is in use.",
                isOn: Binding(
                    get: { layout.joysticks[joystickId]?.hide ?? true },
                    set: { layout.joysticks[joystickId, default: JoystickLayout()].hide = $0 }
                ),
                tint: .green
            )
            
            EditorToggleRow(
                icon: "circle.dashed",
                title: "Always Show Background",
                isOn: Binding(
                    get: { layout.joysticks[joystickId]?.background ?? false },
                    set: { layout.joysticks[joystickId, default: JoystickLayout()].background = $0 }
                ),
                tint: .green
            )
        }
    }
}

enum LayoutEditorNaming {
    static func displayName(for id: String) -> String {
        if id.count == 1 { return id.uppercased() }

        var words: [String] = []
        var current = ""
        for character in id {
            if character.isUppercase && !current.isEmpty {
                words.append(current)
                current = String(character)
            } else {
                current.append(character)
            }
        }
        if !current.isEmpty { words.append(current) }

        return words
            .map { word -> String in
                switch word.lowercased() {
                case "dpad", "d": return "D-Pad"
                case "pad": return "Pad"
                case "abxy": return "ABXY"
                default: return word.prefix(1).uppercased() + word.dropFirst()
                }
            }
            .joined(separator: " ")
            .replacingOccurrences(of: "D Pad", with: "D-Pad")
    }

    static func icon(for buttonId: String) -> String {
        VirtualControllerButton.registered.first { $0.id == buttonId }?.iconName ?? "circle"
    }
}

struct EditorCard<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 14, y: 5)
    }
}

struct EditorCardHeader<Accessory: View>: View {
    let icon: String
    let title: String
    var subtitle: String?
    var tint: Color = .accentColor
    @ViewBuilder var accessory: Accessory
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 32, height: 32)
                .background(Circle().fill(tint.opacity(0.15)))
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer(minLength: 4)
            
            accessory
        }
    }
}

extension EditorCardHeader where Accessory == EmptyView {
    init(icon: String, title: String, subtitle: String? = nil, tint: Color = .accentColor) {
        self.init(icon: icon, title: title, subtitle: subtitle, tint: tint) { EmptyView() }
    }
}

struct EditorResetButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Reset")
                .font(.caption.weight(.semibold))
                .foregroundColor(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.orange.opacity(0.15)))
        }
        .buttonStyle(.plain)
    }
}

struct EditorDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.08))
            .frame(height: 1)
    }
}

struct EditorChip: View {
    let icon: String
    let title: String
    var tint: Color = .accentColor
    var showTitle: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                if showTitle {
                    Text(title)
                        .font(.caption.weight(.medium))
                }
            }
            .foregroundColor(tint == .secondary ? .primary : tint)
            .padding(.horizontal, showTitle ? 12 : 9)
            .padding(.vertical, 8)
            .background(
                Capsule().fill((tint == .secondary ? Color.primary : tint).opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
}

struct EditorSliderRow: View {
    let title: String
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat> = 0.5...2.0
    var step: CGFloat = 0.1
    var tint: Color = .accentColor
    
    private func nudge(_ amount: CGFloat) {
        let next = (value + amount).rounded(toNearest: step)
        value = min(range.upperBound, max(range.lowerBound, next))
        Haptics.shared.play(.light)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f×", value))
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundColor(tint)
            }
            
            HStack(spacing: 10) {
                EditorStepperButton(icon: "minus", tint: tint) { nudge(-step) }
                
                Slider(value: $value, in: range, step: step)
                    .tint(tint)
                
                EditorStepperButton(icon: "plus", tint: tint) { nudge(step) }
            }
        }
    }
}

struct EditorStepperButton: View {
    let icon: String
    var tint: Color = .accentColor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 30, height: 30)
                .background(Circle().fill(tint.opacity(0.15)))
        }
        .buttonStyle(.plain)
    }
}

struct EditorToggleRow: View {
    let icon: String
    let title: String
    var subtitle: String?
    @Binding var isOn: Bool
    var tint: Color = .accentColor
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isOn ? tint : .secondary)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.primary.opacity(0.06)))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.primary)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .toggleStyle(.switch)
        .tint(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

private extension CGFloat {
    func rounded(toNearest step: CGFloat) -> CGFloat {
        guard step > 0 else { return self }
        
        return (self / step).rounded() * step
    }
}

struct EditorSelectionRing: ViewModifier {
    let isSelected: Bool
    var isCircular: Bool = true
    var tint: Color = .blue
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Group {
                    if isCircular {
                        Circle()
                            .strokeBorder(tint, lineWidth: 2.5)
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(tint, lineWidth: 2.5)
                    }
                }
                .padding(-7)
                .shadow(color: tint.opacity(0.6), radius: 6)
                .opacity(isSelected ? 1 : 0)
                .animation(.easeOut(duration: 0.16), value: isSelected)
            }
    }
}

extension View {
    func editorSelectionRing(isSelected: Bool, isCircular: Bool = true, tint: Color = .blue) -> some View {
        modifier(EditorSelectionRing(isSelected: isSelected, isCircular: isCircular, tint: tint))
    }
}
