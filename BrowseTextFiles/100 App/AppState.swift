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

        self.isAutoSaveEnabled = Self.userDefaultsBool(forKey: "isAutoSaveEnabled", defaultValue: true)
        self.autoSaveDelay = Self.userDefaultsInt(forKey: "autoSaveDelay", defaultValue: 2)

        self.newFileTemplates = Self.userDefaultsStringArray(forKey: "newFileTemplates", defaultValue: newFileTemplateDefaults, minSize: 5)
        self.newFileTemplateIndex = Self.userDefaultsInt(forKey: "newFileTemplateIndex", defaultValue: 0)

        let tabKeyActionRaw = Self.userDefaultsInt(forKey: "tabKeyAction", defaultValue: TabKeyAction.default.rawValue)
        self.tabKeyAction =  TabKeyAction(rawValue: tabKeyActionRaw) ?? TabKeyAction.default
        self.indentSize = Self.userDefaultsInt(forKey: "indentSize", defaultValue: 4)

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

    var fontManager = FontManager()
    
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

    func makeNSFontForText() -> NSFont {
        NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: 13)
    }

    func makeFontForText() -> Font {
        .custom(fontName, size: fontSize)
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

    var isAutoSaveEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isAutoSaveEnabled, forKey: "isAutoSaveEnabled")
        }
    }

    var autoSaveDelay: Int {
        didSet {
            UserDefaults.standard.set(autoSaveDelay, forKey: "autoSaveDelay")
        }
    }

    // MARK: - Browser Window

    func openNewBrowserWindow(fromRootURL rootURL: URL?, fileURL: URL?, openWindow: OpenWindowAction) {
        let initParam = FileBrowserInitParam(rootURL: rootURL, fileURL: fileURL)
        openWindow(id: "browser", value: initParam)
    }

    func openNewBrowserWindow(fromFileURL fileURL: URL, openWindow: OpenWindowAction) {
        let rootURL = fileURL.deletingLastPathComponent()
        let initParam = FileBrowserInitParam(rootURL: rootURL, fileURL: fileURL)
        openWindow(id: "browser", value: initParam)
    }

    func openNewBrowserWindow(fromState state: FileBrowserState?, openWindow: OpenWindowAction) {
        openNewBrowserWindow(fromRootURL: state?.rootURL, fileURL: state?.selectedFile?.url, openWindow: openWindow)
    }

    func openNewBrowserWindow(openWindow: OpenWindowAction) {
        openWindow(id: "browser")
    }

    func openNewBrowserWindowFromDialog(openWindow: OpenWindowAction) {
        showFolderOpenPanel { url in
            self.addRecentDocumentURL(url)
            self.openNewBrowserWindow(fromRootURL: url, fileURL: nil, openWindow: openWindow)
        }
    }

    func showFolderOpenPanel(onComplete: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                onComplete(url)
            }
        }
    }

    func showFolderOpenPanelFor(_ window: NSWindow, completion: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.beginSheetModal(for: window) { response in
            if response == .OK, let url = panel.url {
                completion(url)
            }
        }
    }

    // MARK: - RecentDocuments

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

    // MARK: - Tab Key

    enum TabKeyAction: Int {
        case `default` = 0
        case indentWithSpace = 1
    }

    var tabKeyAction: TabKeyAction {
        didSet {
            UserDefaults.standard.set(tabKeyAction.rawValue, forKey: "tabKeyAction")
        }
    }

    var indentSize: Int {
        didSet {
            UserDefaults.standard.set(indentSize, forKey: "indentSize")
        }
    }
}

