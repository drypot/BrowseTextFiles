//
//  SettingsModel.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/17/25.
//


import SwiftUI
import Observation

@Observable
class SettingsModel {
    private let fontNameKey = "Settings.fontName"
    private let fontSizeKey = "Settings.fontSize"
    private let lineHeightKey = "Settings.lineHeight"

    var fontName: String = "Helvetica"
    var fontSize: CGFloat = 13

    var lineHeight: CGFloat = 1.2

    var lineSpacing: CGFloat {
        (lineHeight - 1) * fontSize
    }

    func save() {
        UserDefaults.standard.set(fontName, forKey: fontNameKey)
        UserDefaults.standard.set(fontSize, forKey: fontSizeKey)
        UserDefaults.standard.set(lineHeight, forKey: lineHeightKey)
    }

    func load() {
//        let systemFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
//
//        self.fontName = systemFont.fontName
//        self.fontSize = systemFont.pointSize

        if let savedFontName = UserDefaults.standard.string(forKey: fontNameKey) {
            fontName = savedFontName
        }

        let savedFontSize = UserDefaults.standard.double(forKey: fontSizeKey)
        if savedFontSize > 0 {
            fontSize = CGFloat(savedFontSize)
        }

        let lineHeight = UserDefaults.standard.double(forKey: lineHeightKey)
        if lineHeight > 0 {
            self.lineHeight = CGFloat(lineHeight)
        }
    }

    static func load() -> SettingsModel {
        let settings = SettingsModel()
        settings.load()
        return settings
    }
}
