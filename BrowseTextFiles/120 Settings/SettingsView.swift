//
//  SettingsView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    let fontFamilies = NSFontManager.shared.availableFontFamilies.sorted()

    var body: some View {
        @Bindable var appState = appState
        Form {
            Section {
                Picker("Font", selection: $appState.fontName) {
                    ForEach(fontFamilies, id: \.self) { family in
                        Text(family)
                            .font(.custom(family, size: 13))
                    }
                }
            }
            Section {
                Slider(value: $appState.fontSize, in: 10...30, step: 1) {
                    Text("Font Size ")
                }
                Text(appState.fontSize.formatted())
                    .font(.footnote)
            }
            Section {
                Slider(value: $appState.lineHeight, in: 1.0...3.0, step: 0.1) {
                    Text("Line Height ")
                }
                Text(appState.lineHeight.formatted())
                    .font(.footnote)
            }
            Section {
                let binding = Binding<Double>(
                    get: { Double(appState.autoSavePerSeconds) },
                    set: { appState.autoSavePerSeconds = Int($0) }
                )
                Slider(value: binding, in: 0.0...60.0, step: 2) {
                    Text("Auto Save Per Seconds ")
                }
                Text(appState.autoSavePerSeconds.formatted())
                    .font(.footnote)
            }
        }
        .navigationTitle("Settings")
        .padding()
        .frame(width: 600)
    }
}

#Preview {
    let appState = AppState()
    SettingsView()
        .environment(appState)
}
