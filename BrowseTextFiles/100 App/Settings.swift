//
//  Settings.swift
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

    var autoSavePerSeconds: Int = 10 {
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

        let autoSavePerSeconds = UserDefaults.standard.integer(forKey: "Settings.autoSavePerSeconds")
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

