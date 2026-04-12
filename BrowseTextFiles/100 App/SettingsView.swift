//
//  SettingsView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI
import Observation

@Observable
class SettingsData {

    var fontName: String = "Helvetica" {
        didSet {
            UserDefaults.standard.set(fontName, forKey: "Settings.fontName")
        }
    }

    var fontSize: Double = 13 {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "Settings.fontSize")
        }
    }

    var lineHeight: Double = 1.2 {
        didSet {
            UserDefaults.standard.set(lineHeight, forKey: "Settings.lineHeight")
        }
    }

    var lineHeightMultiple: Double = 0.0 {
        didSet {
            UserDefaults.standard.set(lineHeightMultiple, forKey: "Settings.lineHeightMultiple")
        }
    }

    var lineSpacing: Double {
        (lineHeight - 1) * fontSize
    }

    var autoSavePerSeconds: Double = 10 {
        didSet {
            UserDefaults.standard.set(autoSavePerSeconds, forKey: "Settings.autoSavePerSeconds")
        }
    }

    var recentDocumentURLs: [URL]

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

        let autoSavePerSeconds = UserDefaults.standard.double(forKey: "Settings.autoSavePerSeconds")
        if autoSavePerSeconds > 0 {
            self.autoSavePerSeconds = autoSavePerSeconds
        }

        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    func addRecentDocumentURL(_ url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    func clearRecentDocuments() {
        NSDocumentController.shared.clearRecentDocuments(nil)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }
}

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
                Slider(value: $settings.autoSavePerSeconds, in: 0.0...60.0, step: 2) {
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
