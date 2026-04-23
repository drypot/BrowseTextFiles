//
//  TextBrowserStatus.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers
import MyLibrary

@Observable
final class TextBrowserStatus {
    private var folderTree = FolderTree()
    private var folder = FolderInTextBrowser()

    private(set) var buffer: TextBuffer?
    private var fileMonitor: FileMonitor?

    var activeError: ActiveError?
    var isShowActiveError = false

    var isShowNewFile = false

    private let log = LogStore.shared.log

    var isRootReady: Bool {
        folderTree.isReady
    }

    var isFolderReady: Bool {
        folder.isReady
    }
    
    var isBufferReady: Bool {
        buffer != nil
    }

    var rootURL: URL? {
        folderTree.rootURL
    }

    var rootFolder: Folder? {
        folderTree.rootFolder
    }

    var folderTreeFolders: [Folder] {
        if let rootFolder = folderTree.rootFolder {
            [rootFolder]
        } else {
            []
        }
    }

    var folderFileURLs: [URL] {
        if let urls = folder.fileURLs {
            urls
        } else {
            []
        }
    }

    // MARK: - Folder tree

    func loadFolderTree(from rootURL: URL) {
        do {
            try withSecurityScope(rootURL) {
                try folderTree.loadFolderTree(from: rootURL)
            }
            log("load root: \(rootURL.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("load root: \(message)")
        }
    }

    func reloadFolderTree() {
        guard let rootURL else { return }
        loadFolderTree(from: rootURL)
    }

    var selectedFolder: Folder? {
        self.folderTree.selectedFolder
    }
    
    func selectedFolderBinding() -> Binding<Folder?> {
        Binding<Folder?>(
            get: { self.folderTree.selectedFolder },
            set: { self.updateSelectedFolder(with: $0) }
        )
    }

    private func updateSelectedFolder(with folder: Folder?) {
        folderTree.selectedFolder = folder
        if let folder {
            updateFolderFileList(from: folder.url)
        } else {
            self.folder.reset()
        }
    }

    private func updateSelectedFolder(with url: URL) {
        let folder = folderTree.findFolder(with: url)
        updateSelectedFolder(with: folder)
    }

    func updateSelectedFolderToRoot() {
        updateSelectedFolder(with: folderTree.rootFolder)
    }

    // MARK: - Current folder files

    func updateFolderFileList(from url: URL) {
        do {
            guard let rootURL else { return }
            try withSecurityScope(rootURL) {
                try folder.loadFolder(from: url)
            }
            log("load folder: \(url.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("load folder: \(message)")
        }
    }

    var selectedFileURL: URL? {
        folder.selectedFileURL
    }

    func selectedFileURLBinding() -> Binding<URL?> {
        return Binding<URL?>(
            get: { self.folder.selectedFileURL },
            set: { self.updateSelectedFileURL(with: $0) }
        )
    }

    private func updateSelectedFileURL(with url: URL?) {
        folder.selectedFileURL = url
        if let url {
            updateBuffer(from: url)
        } else {
            resetBuffer()
        }
    }

    private func updateSelectedFileURLChecked(with url: URL) {
        updateSelectedFileURL(with: folder.contains(url) ? url : nil)
    }

    // MARK: - Buffer

    func resetBuffer() {
        saveFileIfEdited()
        if isShowActiveError { return }

        buffer = nil
        fileMonitor = nil
    }

    func updateBuffer(from url: URL) {
        saveFileIfEdited()
        if isShowActiveError { return }

        updateBufferLoop(from: url)
    }

    private func updateBufferLoop(from url: URL) {
        buffer = TextBuffer(url: url)
        fileMonitor = nil
        do {
            guard let rootURL else { return }
            try withSecurityScope(rootURL) {
                try buffer!.loadContent()

                fileMonitor = FileMonitor()
                fileMonitor!.startMonitoring(url) { [weak self] _ in
                    guard let self else { return }
                    self.updateBufferLoop(from: url)
                }

                log("load file: \(url.lastPathComponent)")
            }
        } catch {
            let message = error.localizedDescription
            buffer!.loadError = message
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("load file: \(message)")
        }
    }

    // MARK: - Support init load

    func updateSelectedFolderAndFile(with url: URL) {
        let folderURL = url.deletingLastPathComponent()

        updateSelectedFolder(with: folderURL)
        if isShowActiveError { return }

        if isFolderReady {
            updateSelectedFileURLChecked(with: url)
        } else {
            updateSelectedFolder(with: folderTree.rootFolder)
        }
    }

    // MARK: - Reload

    func reloadAll() {
        saveFileIfEdited()
        if isShowActiveError { return }

        let folderURL = folder.url
        let bufferURL = buffer?.url

        reloadFolderTree()
        if isShowActiveError { return }

        guard let folderURL else { return }
        updateSelectedFolder(with: folderURL)

        guard let bufferURL else { return }
        updateSelectedFileURLChecked(with: bufferURL)

        log("reload all:")
    }

    // MARK: - Save file

    func saveFileIfEdited() {
        guard let buffer, buffer.isEdited, !buffer.hasSaveError else { return }
        saveFile()
    }

    func saveFile() {
        guard let buffer else { return }
        if buffer.loadError != nil { return }
        do {
            guard let rootURL else { return }
            try withSecurityScope(rootURL) {
                try fileMonitor?.disableMonitoringWhile {
                    try buffer.saveContent()
                }
            }
            log("save file: \(buffer.url.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("save file: \(message)")
        }
    }

    // MARK: - New file

    func showNewFileForm() {
        saveFileIfEdited()
        if isShowActiveError { return }

        if !isFolderReady { return }
        isShowNewFile = true
    }
    
    func makeNewFile(path: String) {
        do {
            guard let rootURL else { return }
            let fileManager = FileManager.default
            let url = rootURL.appending(component: path)
            try withSecurityScope(rootURL) {
                if !fileManager.fileExists(atPath: url.path) {
                    let folderURL = url.deletingLastPathComponent()
                    if !fileManager.fileExists(atPath: folderURL.path) {
                        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                        reloadFolderTree()
                    }
                    try "".write(to: url, atomically: true, encoding: .utf8)
                    log("new file: \(path)")
                }
                updateSelectedFolderAndFile(with: url)
            }
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("new file: \(message)")
        }
    }
}



