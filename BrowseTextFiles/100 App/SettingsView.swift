//
//  SettingsView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsData.self) private var settings

    let fontFamilies = NSFontManager.shared.availableFontFamilies.sorted()

    var body: some View {
        @Bindable var settings = settings
        Form {
            Section {
                Picker("Font", selection: $settings.fontName) {
                    ForEach(fontFamilies, id: \.self) { family in
                        Text(family)
                            .font(.custom(family, size: 13))
                    }
                }
            }
            Section {
                Slider(value: $settings.fontSize, in: 10...30, step: 1) {
                    Text("Font Size ")
                }
                Text(settings.fontSize.formatted())
                    .font(.footnote)
            }
            Section {
                Slider(value: $settings.lineHeight, in: 1.0...3.0, step: 0.1) {
                    Text("Line Height ")
                }
                Text(settings.lineHeight.formatted())
                    .font(.footnote)
            }
            Section {
                let binding = Binding<Double>(
                    get: { Double(settings.autoSavePerSeconds) },
                    set: { settings.autoSavePerSeconds = Int($0) }
                )
                Slider(value: binding, in: 0.0...60.0, step: 2) {
                    Text("Auto Save Per Seconds ")
                }
                Text(settings.autoSavePerSeconds.formatted())
                    .font(.footnote)
            }
        }
        .navigationTitle("Settings")
        .padding()
        .frame(width: 600)
    }
}

#Preview {
    let settings = SettingsData()
    SettingsView()
        .environment(settings)
}
