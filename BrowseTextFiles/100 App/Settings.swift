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

    var fontName: String {
        didSet {
            UserDefaults.standard.set(fontName, forKey: "fontName")
        }
    }

    var fontSize: Double {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }

    var lineHeight: Double {
        didSet {
            UserDefaults.standard.set(lineHeight, forKey: "lineHeight")
        }
    }

    var lineSpacing: Double {
        (lineHeight - 1) * fontSize
    }

    var autoSavePerSeconds: Int {
        didSet {
            UserDefaults.standard.set(autoSavePerSeconds, forKey: "autoSavePerSeconds")
        }
    }

    var newFileTemplates: [String] = [] {
        didSet {
            UserDefaults.standard.set(newFileTemplates, forKey: "newFileTemplates")
        }
    }

    var recentDocumentURLs: [URL]

    init() {
        //        let systemFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        //
        //        self.fontName = systemFont.fontName
        //        self.fontSize = systemFont.pointSize

        if let fontName = UserDefaults.standard.string(forKey: "fontName") {
            self.fontName = fontName
        } else {
            self.fontName = "SF Pro"
        }

        let fontSize = UserDefaults.standard.double(forKey: "fontSize")
        self.fontSize = fontSize > 0 ? fontSize : 16

        let lineHeight = UserDefaults.standard.double(forKey: "lineHeight")
        self.lineHeight = lineHeight > 0 ? lineHeight : 1.3

        let autoSavePerSeconds = UserDefaults.standard.integer(forKey: "autoSavePerSeconds")
        self.autoSavePerSeconds = autoSavePerSeconds > 0 ? autoSavePerSeconds : 10

        if let newFileTemplates = UserDefaults.standard.stringArray(forKey: "newFileTemplates") {
            self.newFileTemplates = newFileTemplates
        } else {
            self.newFileTemplates = ["template1", "template2", "template3"]
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

