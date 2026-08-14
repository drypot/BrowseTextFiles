//
//  SettingsView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var app

    var body: some View {
        @Bindable var app = app
        Form {
            Section("New File") {
                TextField("New file name", text: $app.newFileName)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Font") {
                LabeledContent("Font: \(app.fontName)") {
                    Button("Change Font") {
                        app.showFontPanel()
                    }
                }

                Slider(value: $app.fontSize, in: 8...36, step: 1) {
                    Text("Font size: \(app.fontSize.formatted()) pt")
                }
                .controlSize(.mini)

                Slider(value: $app.lineHeightMultiple, in: 1.0...3.0, step: 0.1) {
                    Text("Line height: \(app.lineHeightMultiple.formatted())x")
                }
                .controlSize(.mini)
            }

            Section("Auto Save") {
                Toggle("Auto save enabled", isOn: $app.isAutoSaveEnabled)
                    .controlSize(.mini)
                    .toggleStyle(.switch)

                let autoSaveAfterbinding = Binding<Double>(
                    get: { Double(app.autoSaveDelay) },
                    set: { app.autoSaveDelay = Int($0) }
                )
                Slider(value: autoSaveAfterbinding, in: 2.0...60.0, step: 2) {
                    Text("Auto save after \(app.autoSaveDelay.formatted()) seconds")
                }
                .disabled(!app.isAutoSaveEnabled)
                .controlSize(.mini)
            }

            Section(header: Text("Tab Key")) {
                let tabKeyActionBinding = Binding<Int>(
                    get: { app.tabKeyAction.rawValue },
                    set: { app.tabKeyAction = AppState.TabKeyAction(rawValue: $0) ?? .default }
                )
                Picker("Tab key action", selection: tabKeyActionBinding) {
                    Text("Insert Tab").tag(AppState.TabKeyAction.default.rawValue)
                    Text("Indent with Space").tag(AppState.TabKeyAction.indentWithSpace.rawValue)
                }

                let indentSizeBinding = Binding<Double>(
                    get: { Double(app.indentSize) },
                    set: { app.indentSize = Int($0) }
                )
                Slider(value: indentSizeBinding, in: 2.0...16.0, step: 1) {
                    Text("Indent with \(app.indentSize.formatted()) spaces")
                }
                .disabled(app.tabKeyAction != .indentWithSpace)
                .controlSize(.mini)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .fixedSize()
        //.frame(minWidth: 500, minHeight: 500)
    }
}

//#Preview {
//    SettingsView(app: AppState())
//}
