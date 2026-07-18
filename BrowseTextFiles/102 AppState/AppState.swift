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

    var newFileName: String {
        didSet {
            UserDefaults.standard.set(newFileName, forKey: "newFileName")
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

    private var fontPanelFont: NSFont?

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

    @ObservationIgnored weak var lastRootState: BrowserStateRoot?
    @ObservationIgnored var lastBrowserWindowSize: CGSize?

    @ObservationIgnored private var windowRectStoreForStringUUID: [StringAndUUID: CGRect] = [:]
    @ObservationIgnored private var windowRectStoreForString: [String: CGRect] = [:]

    @ObservationIgnored var newWindowRootURL: URL?
    @ObservationIgnored var newWindowFileURL: URL?

    var recentDocumentURLs: [URL]

    @ObservationIgnored private let newFileTemplateDefaults = [
        "{selected-folder}/Untitled.md",
        "{year}/{month}/{year}-{month}-{day}-{weekday-short}.md",
    ]

    init() {
        let defaults = UserDefaults.standard

        self.newFileName = defaults.string(forKey: "newFileName", defaultValue: "Untitled.md")
        self.newFileTemplates = defaults.stringArray(forKey: "newFileTemplates", defaultValue: newFileTemplateDefaults, minSize: 5)
        self.newFileTemplateIndex = defaults.integer(forKey: "newFileTemplateIndex", defaultValue: 0)

        self.fontName = defaults.string(forKey: "fontName", defaultValue: "SF Pro")
        self.fontSize = defaults.double(forKey: "fontSize", defaultValue: 16)
        self.lineHeightMultiple = defaults.double(forKey: "lineHeightMultiple", defaultValue: 1.3)

        self.isAutoSaveEnabled = defaults.bool(forKey: "isAutoSaveEnabled", defaultValue: true)
        self.autoSaveDelay = defaults.integer(forKey: "autoSaveDelay", defaultValue: 2)

        let tabKeyActionRaw = defaults.integer(forKey: "tabKeyAction", defaultValue: TabKeyAction.default.rawValue)
        self.tabKeyAction =  TabKeyAction(rawValue: tabKeyActionRaw) ?? TabKeyAction.default
        self.indentSize = defaults.integer(forKey: "indentSize", defaultValue: 4)

        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    // MARK: - Font

    func makeNSFont() -> NSFont {
        NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: 13)
    }

    func makeFont() -> Font {
        .custom(fontName, size: fontSize)
    }

    func showFontPanel() {
        self.fontPanelFont = makeNSFont()
        guard let fontPanelFont else { return }

        let manager = NSFontManager.shared
        manager.target = self
        manager.action = #selector(onFontPanelChange(_:))

        NSFontPanel.shared.setPanelFont(fontPanelFont, isMultiple: false)
        NSFontPanel.shared.makeKeyAndOrderFront(nil)
    }

    @objc func onFontPanelChange(_ sender: Any?) {
        guard let manager = sender as? NSFontManager else { return }
        guard let fontPanelFont else { return }

        let newFont = manager.convert(fontPanelFont)
        self.fontPanelFont = newFont

        fontName = newFont.fontName
        fontSize = newFont.pointSize
    }

    // MARK: - New File Templates

    func resetNewFileTemplatesToDefaults() {
        let minSize = self.newFileTemplates.count
        self.newFileTemplates = UserDefaults.standard.stringArray(forKey: "_NoneKey_", defaultValue: newFileTemplateDefaults, minSize: minSize)
    }

    // MARK: - Browser Window

    func saveBrowserWindowSize(_ size: CGSize) {
        lastBrowserWindowSize = size
        //print("save browser window size: \(size)")
    }

    func openNewBrowserWindow(fromFolderURL folderURL: URL?, fileURL: URL?, openWindow: OpenWindowAction) {
        newWindowRootURL = folderURL
        newWindowFileURL = fileURL
        openWindow(id: "browser")
    }

    func openNewBrowserWindow(fromFileURL fileURL: URL?, openWindow: OpenWindowAction) {
        let rootURL = fileURL?.deletingLastPathComponent()
        openNewBrowserWindow(fromFolderURL: rootURL, fileURL: fileURL, openWindow: openWindow)
    }

    func openNewBrowserWindow(openWindow: OpenWindowAction) {
        openNewBrowserWindow(fromFolderURL: nil, fileURL: nil, openWindow: openWindow)
    }

    func openNewBrowserWindowFromDialog(openWindow: OpenWindowAction) {
        showFolderOpenPanel { url in
            self.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
        }
    }

    func showFolderOpenPanel(onComplete: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
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
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        panel.beginSheetModal(for: window) { response in
            if response == .OK, let url = panel.url {
                completion(url)
            }
        }
    }

    // MARK: - RecentDocuments

    func addRecentDocumentURL(_ url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    func clearRecentDocuments() {
        NSDocumentController.shared.clearRecentDocuments(nil)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    // MARK: - Window Position

    func saveWindowRect(_ rect: CGRect, for string: String, uuid: UUID) {
        windowRectStoreForStringUUID[StringAndUUID(string: string, uuid: uuid)] = rect
        windowRectStoreForString[string] = rect
        //print("save window rect: \(rect)")
    }

    func makeWindowPlacement(for string: String, uuid: UUID?, visibleRect: CGRect, defaultSize: CGSize? = nil) -> WindowPlacement {
        var invertedPosition: CGPoint? = nil
        var position: CGPoint? = nil
        var size: CGSize? = nil

        if let uuid, let rect = windowRectStoreForStringUUID[StringAndUUID(string: string, uuid: uuid)] {
            invertedPosition = rect.origin
            size = rect.size
        } else if let rect = windowRectStoreForString[string] {
            size = rect.size
        }

        if let invertedPosition, let size {
            position = CGPoint(x: invertedPosition.x,
                               y: visibleRect.maxY - invertedPosition.y - size.height)
        }

        //print("restore window rect: \(position ?? .zero), \(size ?? .zero)")
        return WindowPlacement(position, size: size ?? defaultSize)
    }

    // MARK: - Search Window

    // func openSearchWindow(for stateRoot: RootState, openWindow: OpenWindowAction) {
    //     guard stateRoot.browserState.status == .ready else { return }
    //     lastRootState = stateRoot
    //     openWindow(id: "search", value: stateRoot.browserState.id)
    //     stateRoot.searchState.isSearchWindowPresented = true
    // }

    // func toggleSearchWindow(for stateRoot: RootState, openWindow: OpenWindowAction, dismissWindow: DismissWindowAction) {
    //     guard stateRoot.browserState.status == .ready else { return }
    //     if stateRoot.searchState.isSearchWindowPresented {
    //         dismissWindow(id: "search", value: stateRoot.browserState.id)
    //         stateRoot.searchState.isSearchWindowPresented = false
    //     } else {
    //         openSearchWindow(for: stateRoot, openWindow: openWindow)
    //     }
    // }

    // MARK: - History Window

    // func openHistoryWindow(for stateRoot: RootState, openWindow: OpenWindowAction) {
    //     guard stateRoot.browserState.status == .ready else { return }
    //     lastRootState = stateRoot
    //     openWindow(id: "history", value: stateRoot.browserState.id)
    //     stateRoot.historyState.isHistoryWindowPresented = true
    // }

    // func toggleHistoryWindow(for stateRoot: RootState, openWindow: OpenWindowAction, dismissWindow: DismissWindowAction) {
    //     guard stateRoot.browserState.status == .ready else { return }
    //     if stateRoot.historyState.isHistoryWindowPresented {
    //         dismissWindow(id: "history", value: stateRoot.browserState.id)
    //         stateRoot.historyState.isHistoryWindowPresented = false
    //     } else {
    //         openHistoryWindow(for: stateRoot, openWindow: openWindow)
    //     }
    // }

    // MARK: - Finder

    func openFinder(with url: URL?) {
        guard let url else { return }
        let path = url.path(percentEncoded: false)
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        } else {
            let folderURL = url.deletingLastPathComponent()
            NSWorkspace.shared.open(folderURL)
        }
    }
}

