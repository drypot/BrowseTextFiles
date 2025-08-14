//
//  SettingsView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/17/25.
//


import SwiftUI

struct SettingsView: View {
    @Bindable var appSettings: AppSettings

    let fontFamilies = NSFontManager.shared.availableFontFamilies.sorted()

    var body: some View {
        Form {
            Section {
                Picker("Font", selection: $appSettings.fontName) {
                    ForEach(fontFamilies, id: \.self) { family in
                        Text(family).font(.custom(family, size: 13))
                    }
                }
            }

            Section {
                Slider(value: $appSettings.fontSize, in: 10...30, step: 1) {
                    Text("Font Size ")
                }
                Text(String(format: "%.0f pt", appSettings.fontSize))
                    .font(.footnote)
            }

            Section {
                Slider(value: $appSettings.lineHeight, in: 1.0...3.0, step: 0.1) {
                    Text("Line Height ")
                }
                Text(String(format: "%.1fx", appSettings.lineHeight))
                    .font(.footnote)
            }
        }
        .navigationTitle("Settings")
        .onDisappear {
            appSettings.save()
        }
        .padding()
        .frame(width: 300)
    }
}
