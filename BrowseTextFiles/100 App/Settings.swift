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

    private let newFileTemplateDefaults = [
        "{current-folder}/Untitled.txt",
        "{year}/{month}/{year}-{month}-{day}-{weekday-short}.txt",
    ]

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

    var newFileTemplates: [String] {
        didSet {
            UserDefaults.standard.set(newFileTemplates, forKey: "newFileTemplates")
        }
    }

    var newFileTemplateIndex: Int {
        didSet {
            UserDefaults.standard.set(newFileTemplateIndex, forKey: "newFileTemplateIndex")
        }
    }

    var recentDocumentURLs: [URL]

    init() {
        self.fontName = Self.string(forKey: "fontName", defaultValue: "SF Pro")
        self.fontSize = Self.double(forKey: "fontSize", defaultValue: 16)
        self.lineHeight = Self.double(forKey: "lineHeight", defaultValue: 1.3)

        self.autoSavePerSeconds = Self.int(forKey: "autoSavePerSeconds", defaultValue: 10)

        self.newFileTemplates = Self.stringArray(forKey: "newFileTemplates", defaultValue: newFileTemplateDefaults, minSize: 5)
        self.newFileTemplateIndex = Self.int(forKey: "newFileTemplateIndex", defaultValue: 0)

        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    private static func double(forKey key: String, defaultValue: Double) -> Double {
        let value = UserDefaults.standard.double(forKey: key)
        return value > 0 ? value : defaultValue
    }

    private static func int(forKey key: String, defaultValue: Int) -> Int {
        let value = UserDefaults.standard.integer(forKey: key)
        return value > 0 ? value : defaultValue
    }

    private static func string(forKey key: String, defaultValue: String) -> String {
        let value = UserDefaults.standard.string(forKey: key)
        return value ?? defaultValue
    }

    private static func stringArray(forKey key: String, defaultValue: [String], minSize: Int = 0) -> [String] {
        var value = UserDefaults.standard.stringArray(forKey: key) ?? defaultValue
        if minSize > 0 {
            while value.count < minSize {
                value.append("")
            }
        }
        return value
    }

    func addRecentDocumentURL(_ url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    func clearRecentDocuments() {
        NSDocumentController.shared.clearRecentDocuments(nil)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    func resetNewFileTemplatesToDefaults() {
        let minSize = self.newFileTemplates.count
        self.newFileTemplates = Self.stringArray(forKey: "_NoneKey_", defaultValue: newFileTemplateDefaults, minSize: minSize)
    }
}

