//
//  AppState.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI
import Observation

@Observable
class AppState {

    init() {
        self.fontName = Self.userDefaultsString(forKey: "fontName", defaultValue: "SF Pro")
        self.fontSize = Self.userDefaultsDouble(forKey: "fontSize", defaultValue: 16)
        self.lineHeightMultiple = Self.userDefaultsDouble(forKey: "lineHeightMultiple", defaultValue: 1.3)

        self.autoSaveEnabled = Self.userDefaultsBool(forKey: "autoSaveEnabled", defaultValue: true)
        self.autoSaveAfterSeconds = Self.userDefaultsInt(forKey: "autoSaveAfterSeconds", defaultValue: 2)

        self.newFileTemplates = Self.userDefaultsStringArray(forKey: "newFileTemplates", defaultValue: newFileTemplateDefaults, minSize: 5)
        self.newFileTemplateIndex = Self.userDefaultsInt(forKey: "newFileTemplateIndex", defaultValue: 0)

        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    // MARK: - UserDefaults

    private static func userDefaultsDouble(forKey key: String, defaultValue: Double) -> Double {
        if UserDefaults.standard.object(forKey: key) == nil {
            defaultValue
        } else {
            UserDefaults.standard.double(forKey: key)
        }
    }

    private static func userDefaultsInt(forKey key: String, defaultValue: Int) -> Int {
        if UserDefaults.standard.object(forKey: key) == nil {
            defaultValue
        } else {
            UserDefaults.standard.integer(forKey: key)
        }
    }

    private static func userDefaultsBool(forKey key: String, defaultValue: Bool) -> Bool {
        if UserDefaults.standard.object(forKey: key) == nil {
            defaultValue
        } else {
            UserDefaults.standard.bool(forKey: key)
        }
    }

    private static func userDefaultsString(forKey key: String, defaultValue: String) -> String {
        UserDefaults.standard.string(forKey: key) ?? defaultValue
    }

    private static func userDefaultsStringArray(forKey key: String, defaultValue: [String], minSize: Int = 0) -> [String] {
        var strings = UserDefaults.standard.stringArray(forKey: key) ?? defaultValue
        while strings.count < minSize {
            strings.append("")
        }
        return strings
    }

    // MARK: - Font

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

    var lineHeightMultiple: Double {
        didSet {
            UserDefaults.standard.set(lineHeightMultiple, forKey: "lineHeightMultiple")
        }
    }

    var lineSpacing: Double {
        (lineHeightMultiple - 1) * fontSize
    }

    // MARK: - New File Templates

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

    private let newFileTemplateDefaults = [
        "{current-folder}/Untitled.txt",
        "{year}/{month}/{year}-{month}-{day}-{weekday-short}.txt",
    ]

    func resetNewFileTemplatesToDefaults() {
        let minSize = self.newFileTemplates.count
        self.newFileTemplates = Self.userDefaultsStringArray(forKey: "_NoneKey_", defaultValue: newFileTemplateDefaults, minSize: minSize)
    }

    // MARK: - AutoSave

    var autoSaveEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoSaveEnabled, forKey: "autoSaveEnabled")
        }
    }

    var autoSaveAfterSeconds: Int {
        didSet {
            UserDefaults.standard.set(autoSaveAfterSeconds, forKey: "autoSaveAfterSeconds")
        }
    }

    // MARK: - Browser Window

    func openNewBrowserWindow(from currentState: FileBrowserState?, openWindow: OpenWindowAction) {
        if let state = currentState {
            let initParam = FileBrowserWindow.InitParam(rootURL: state.rootURL, fileURL: state.selectedFile?.url)
            openWindow(id: "browser", value: initParam)
        } else {
            openWindow(id: "browser")
        }
    }

    func openNewBrowserWindowFromDialog(openWindow: OpenWindowAction) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            if let url = panel.url {
                let initParam = FileBrowserWindow.InitParam(rootURL: url)
                openWindow(id: "browser", value: initParam)
            }
        }
    }

    // MARK: - RecentDocuments

    @ObservationIgnored
    var recentDocumentURLs: [URL]

    func addRecentDocumentURL(_ url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    func clearRecentDocuments() {
        NSDocumentController.shared.clearRecentDocuments(nil)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    // MARK: - Search Window

    @ObservationIgnored
    weak var currentFileBrowserState: FileBrowserState? = nil

    func openSearchWindow(for state: FileBrowserState?, openWindow: OpenWindowAction) {
        guard let state else { return }
        currentFileBrowserState = state
        openWindow(id: "search", value: state.id)
    }

}
