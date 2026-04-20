//
//  TextBrowserStatus.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MyLibrary

@Observable
final class TextBrowserStatus {
    private(set) var rootURL: URL?
    private(set) var rootFolder: Folder?

    private(set) var folders: [Folder]?

    private(set) var folderFileURLs: [URL]?

    private(set) var buffer: TextBuffer?
    private var fileMonitor: FileMonitor?

    var activeError: ActiveError?
    var isShowActiveError = false

    var isShowNewFile = false

    private let log = LogStore.shared.log

    var selectedFolder: Folder? {
        didSet {
            loadSelectedFolder()
        }
    }

    var selectedFileURL: URL? {
        didSet {
            loadSelectedFile()
        }
    }

    var isRootReady: Bool {
        return rootFolder != nil
    }

    var isFolderReady: Bool {
        return selectedFolder != nil
    }
    
    var isBufferReady: Bool {
        return buffer != nil
    }

    func reloadAll() {
        guard saveFileAndCheckResult() else { return }

        let savedFileURL = selectedFileURL
        loadRoot(from: rootURL)
        loadFolder(from: savedFileURL)
        loadFile(from: savedFileURL)
        log("reloadAll:")
    }

    func loadRoot(from rootURL: URL?) {
        self.rootURL = nil
        rootFolder = nil
        folders = nil

        guard let rootURL else { return }
        do {
            try withSecurityScope(rootURL) {
                rootFolder = try FolderTreeBuilder().build(from: rootURL)
                guard let rootFolder else { return }
                self.rootURL = rootURL
                folders = [rootFolder]
            }
            log("load root: \(rootURL.lastPathComponent)")
        } catch {
            activeError = ActiveError(message: error.localizedDescription)
            isShowActiveError = true
            log("load root: \(error.localizedDescription)")
        }
    }

    // data driven 방식으로,
    // selectedFolder 를 변경하면 다른 프로퍼티들을 자동 로딩한다.

    func loadFolder(from url: URL?) {
        guard let rootFolder else { return }
        guard let url else { return }

        let folderURL = url.deletingLastPathComponent()
        if let folder = rootFolder.findChild(with: folderURL) {
            selectedFolder = folder
        } else {
            selectedFolder = nil
        }
    }

    func loadFile(from url: URL?) {
        guard rootFolder != nil else { return }
        guard let url else { return }

        if let folderFileURLs, folderFileURLs.contains(url) {
            selectedFileURL = url
        } else {
            selectedFileURL = nil
        }
    }

    func loadRootFolder() {
        selectedFolder = rootFolder
    }

    private func loadSelectedFolder() {
        folderFileURLs = nil

        guard let rootURL else { return }
        guard let folder = selectedFolder else { return }
        do {
            try withSecurityScope(rootURL) {
                folderFileURLs = try TextFileURLCollector().collectShallowly(from: folder.url)
                folderFileURLs?.sort { $0.lastPathComponent < $1.lastPathComponent }
            }
            log("load folder: \(folder.name)")
        } catch {
            activeError = ActiveError(message: error.localizedDescription)
            isShowActiveError = true
            log("load folder: \(error.localizedDescription)")
        }
    }

    private func loadSelectedFile(skipAutoSave: Bool = false) {
        if !skipAutoSave {
            guard saveFileAndCheckResult() else { return }
        }

        buffer = nil
        fileMonitor = nil

        guard let rootURL else { return }
        guard let url = selectedFileURL else { return }
        let fileName = url.lastPathComponent

        let buffer = TextBuffer(url: url)
        self.buffer = buffer
        do {
            try withSecurityScope(rootURL) {
                try buffer.loadContent()
                
                fileMonitor = FileMonitor()
                fileMonitor?.startMonitoring(url) { [weak self] _ in
                    guard let self else { return }
                    self.loadSelectedFile(skipAutoSave: true)
                }

                log("load file: \(fileName)")
            }
        } catch {
            let message = error.localizedDescription

            buffer.loadError = message

            activeError = ActiveError(message: message)
            isShowActiveError = true

            log("load file: \(message)")
        }
    }

    func saveFileAndCheckResult() -> Bool {
        saveFileIfEdited()
        return !isShowActiveError
    }

    func saveFileIfEdited() {
        guard let buffer, buffer.isEdited, !buffer.hasSaveError else { return }
        saveFile()
    }

    func saveFile() {
        guard let rootURL else { return }
        guard let buffer else { return }
        guard buffer.loadError == nil else { return }
        let fileName = buffer.url.lastPathComponent
        do {
            try withSecurityScope(rootURL) {
                try fileMonitor?.disableMonitoringWhile {
                    try buffer.saveContent()
                }
            }
            log("save file: \(fileName)")
        } catch {
            activeError = ActiveError(message: error.localizedDescription)
            isShowActiveError = true
            log("save file: \(error.localizedDescription)")
        }
    }

    func showNewFileForm() {
        guard saveFileAndCheckResult() else { return }
        guard isFolderReady else { return }
        isShowNewFile = true
    }
    
    func makeNewFile(path: String) {
        guard let rootURL else { return }
        let url = rootURL.appending(component: path)
        let fileManager = FileManager.default
        do {
            try withSecurityScope(rootURL) {
                if !fileManager.fileExists(atPath: url.path) {
                    let folderURL = url.deletingLastPathComponent()
                    if !fileManager.fileExists(atPath: folderURL.path) {
                        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                        loadRoot(from: rootURL)
                    }
                    try "".write(to: url, atomically: true, encoding: .utf8)
                    log("new file: \(path)")
                }
                loadFolder(from: url)
                loadFile(from: url)
            }
        } catch {
            activeError = ActiveError(message: error.localizedDescription)
            isShowActiveError = true
            log("new file: \(error.localizedDescription)")
        }
    }
}

