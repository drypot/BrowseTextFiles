//
//  SettingsView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI
import Observation

@Observable
class SettingsModel {

    var fontName: String = "Helvetica" {
        didSet {
            UserDefaults.standard.set(fontName, forKey: "Settings.fontName")
        }
    }

    var fontSize: CGFloat = 13 {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "Settings.fontSize")
        }
    }

    var lineHeight: CGFloat = 1.2 {
        didSet {
            UserDefaults.standard.set(lineHeight, forKey: "Settings.lineHeight")
        }
    }

    var lineHeightMultiple: CGFloat = 0.0 {
        didSet {
            UserDefaults.standard.set(lineHeightMultiple, forKey: "Settings.lineHeightMultiple")
        }
    }

    var lineSpacing: CGFloat {
        (lineHeight - 1) * fontSize
    }

    init() {
        //        let systemFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        //
        //        self.fontName = systemFont.fontName
        //        self.fontSize = systemFont.pointSize

        if let fontName = UserDefaults.standard.string(forKey: "Settings.fontName") {
            self.fontName = fontName
        }

        let fontSize = UserDefaults.standard.double(forKey: "Settings.fontSize")
        if fontSize > 0 {
            self.fontSize = CGFloat(fontSize)
        }

        let lineHeight = UserDefaults.standard.double(forKey: "Settings.lineHeight")
        if lineHeight > 0 {
            self.lineHeight = CGFloat(lineHeight)
        }

        let lineHeightMultiple = UserDefaults.standard.double(forKey: "Settings.lineHeightMultiple")
        if lineHeightMultiple > 0 {
            self.lineHeightMultiple = CGFloat(lineHeightMultiple)
        }
    }

}

struct SettingsView: View {
    @Environment(SettingsModel.self) private var settings

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
        .padding()
        .frame(width: 400)
    }
}
