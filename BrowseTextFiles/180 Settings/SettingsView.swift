//
//  SettingsView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var appState = appState
        Form {
            Section("Font") {
                LabeledContent("Font: \(appState.fontName)") {
                    Button("Change Font") {
                        appState.showFontPanel()
                    }
                }

                Slider(value: $appState.fontSize, in: 8...36, step: 1) {
                    Text("Font size: \(appState.fontSize.formatted()) pt")
                }
                .controlSize(.mini)

                Slider(value: $appState.lineHeightMultiple, in: 1.0...3.0, step: 0.1) {
                    Text("Line height: \(appState.lineHeightMultiple.formatted())x")
                }
                .controlSize(.mini)
            }

            Section("Auto Save") {
                Toggle("Auto save enabled", isOn: $appState.isAutoSaveEnabled)
                    .controlSize(.mini)
                    .toggleStyle(.switch)

                let autoSaveAfterbinding = Binding<Double>(
                    get: { Double(appState.autoSaveDelay) },
                    set: { appState.autoSaveDelay = Int($0) }
                )
                Slider(value: autoSaveAfterbinding, in: 2.0...60.0, step: 2) {
                    Text("Auto save after \(appState.autoSaveDelay.formatted()) seconds")
                }
                .disabled(!appState.isAutoSaveEnabled)
                .controlSize(.mini)
            }

            Section(header: Text("Tab Key")) {
                let tabKeyActionBinding = Binding<Int>(
                    get: { appState.tabKeyAction.rawValue },
                    set: { appState.tabKeyAction = AppState.TabKeyAction(rawValue: $0) ?? .default }
                )
                Picker("Tab key action", selection: tabKeyActionBinding) {
                    Text("Insert Tab").tag(AppState.TabKeyAction.default.rawValue)
                    Text("Indent with Space").tag(AppState.TabKeyAction.indentWithSpace.rawValue)
                }

                let indentSizeBinding = Binding<Double>(
                    get: { Double(appState.indentSize) },
                    set: { appState.indentSize = Int($0) }
                )
                Slider(value: indentSizeBinding, in: 2.0...16.0, step: 1) {
                    Text("Indent with \(appState.indentSize.formatted()) spaces")
                }
                .disabled(appState.tabKeyAction != .indentWithSpace)
                .controlSize(.mini)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .frame(minWidth: 500, minHeight: 500)
    }
}

//#Preview {
//    SettingsView(appState: AppState())
//}
