//
//  SettingsModel.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/17/25.
//


import SwiftUI
import Observation

@Observable
class AppSettings {

    static let shared = AppSettings()

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

    private init() {
//        let systemFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
//
//        self.fontName = systemFont.fontName
//        self.fontSize = systemFont.pointSize

        let savedFontSize = UserDefaults.standard.double(forKey: "Settings.fontSize")
        if savedFontSize > 0 {
            fontSize = CGFloat(savedFontSize)
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
