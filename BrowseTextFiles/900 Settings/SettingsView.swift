//
//  SettingsView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/17/25.
//


import SwiftUI

struct SettingsView: View {
    @Bindable var settings: SettingsModel

    let fontFamilies = NSFontManager.shared.availableFontFamilies.sorted()

    var body: some View {
        Form {
            Section {
                Picker("Font", selection: $settings.fontName) {
                    ForEach(fontFamilies, id: \.self) { family in
                        Text(family).font(.custom(family, size: 13))
                    }
                }
            }

            Section {
                Slider(value: $settings.fontSize, in: 10...30, step: 1) {
                    Text("Font Size ")
                }
                Text(String(format: "%.0f pt", settings.fontSize))
                    .font(.footnote)
            }

            Section {
                Slider(value: $settings.lineHeight, in: 1.0...3.0, step: 0.1) {
                    Text("Line Height ")
                }
                Text(String(format: "%.1fx", settings.lineHeight))
                    .font(.footnote)
            }
        }
        .navigationTitle("Settings")
        .onDisappear {
            settings.save()
        }
        .padding()
        .frame(width: 300)
    }
}
