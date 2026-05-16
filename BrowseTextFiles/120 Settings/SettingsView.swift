//
//  SettingsView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    let sliderWidth: CGFloat = 240

    var body: some View {
        @Bindable var appState = appState
        Form {
            Section(header: Text("Font")) {
                HStack {
                    Text("Font: \(appState.fontName)")
                    Spacer()
                    Button("Change Font") {
                        let initFont = appState.makeNSFontForText()
                        appState.fontManager.showFontPanel(initialFont: initFont) { newFont in
                            appState.fontName = newFont.fontName
                            appState.fontSize = newFont.pointSize
                        }
                    }
                }
                HStack {
                    Text("Font size: \(appState.fontSize.formatted()) pt")
                        .frame(width: 180, alignment: .leading)
                    Slider(value: $appState.fontSize, in: 8...36, step: 1)
                        .controlSize(.mini)
                }
                HStack {
                    Text("Line height: \(appState.lineHeightMultiple.formatted())x")
                        .frame(width: 180, alignment: .leading)
                    Slider(value: $appState.lineHeightMultiple, in: 1.0...3.0, step: 0.1)
                        .controlSize(.mini)
                }
            }

            Section(header: Text("Auto Save")) {
                HStack {
                    Text("Auto save enabled")
                    Spacer()
                    Toggle("", isOn: $appState.isAutoSaveEnabled)
                        .labelsHidden()
                        .controlSize(.mini)
                        .toggleStyle(.switch)
                }
                HStack {
                    Text("Auto save after \(appState.autoSaveDelay.formatted()) seconds")
                        .frame(width: 180, alignment: .leading)
                    let binding = Binding<Double>(
                        get: { Double(appState.autoSaveDelay) },
                        set: { appState.autoSaveDelay = Int($0) }
                    )
                    Slider(value: binding, in: 2.0...60.0, step: 2)
                        .disabled(!appState.isAutoSaveEnabled)
                        .controlSize(.mini)
                }
            }

            Section(header: Text("Tab Key")) {
                HStack {
                    Text("Tab key action")
                    let binding = Binding<Int>(
                        get: { appState.tabKeyAction.rawValue },
                        set: { appState.tabKeyAction = AppState.TabKeyAction(rawValue: $0) ?? .default }
                    )
                    Picker("", selection: binding) {
                        Text("Insert Tab").tag(AppState.TabKeyAction.default.rawValue)
                        Text("Indent with Space").tag(AppState.TabKeyAction.indentWithSpace.rawValue)
                    }
                }
                HStack {
                    Text("Indent with \(appState.indentSize.formatted()) spaces")
                        .frame(width: 180, alignment: .leading)
                    let binding = Binding<Double>(
                        get: { Double(appState.indentSize) },
                        set: { appState.indentSize = Int($0) }
                    )
                    Slider(value: binding, in: 2.0...16.0, step: 1)
                        .disabled(appState.tabKeyAction != .indentWithSpace)
                        .controlSize(.mini)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .frame(width: 600, height: 500)
    }
}

#Preview {
    let appState = AppState()
    SettingsView()
        .environment(appState)
}
