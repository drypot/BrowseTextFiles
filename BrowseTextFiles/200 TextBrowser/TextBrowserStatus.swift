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
    var selectedFolder: Folder?

    private(set) var folderFileURLs: [URL]?
    var selectedFileURL: URL?

    private(set) var buffer: TextBuffer?
    private var fileMonitor: FileMonitor?

    var activeError: ActiveError?
    var isShowActiveError = false

    private let log = LogStore.shared.log

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
        let savedFileURL = selectedFileURL

        loadRoot(from: rootURL)
        loadFolderAndFile(from: savedFileURL)
        log("reloadAll:")
    }

    private func resetRoot() {
        rootURL = nil
        rootFolder = nil
        folders = nil
        resetFolder()
    }

    private func resetFolder() {
        selectedFolder = nil
        folderFileURLs = nil
        resetFile()
    }

    private func resetFile() {
        selectedFileURL = nil
        buffer = nil
        fileMonitor = nil
    }

    func loadRoot(from rootURL: URL?) {
        resetRoot()

        guard let rootURL else { return }
        do {
            try withSecurityScope(rootURL) {
                rootFolder = try FolderTreeBuilder().build(from: rootURL)
                guard let rootFolder else { return }
                self.rootURL = rootURL
                folders = [rootFolder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
            }
        } catch {
            activeError = ActiveError(message: error.localizedDescription)
            isShowActiveError = true
            log("load root: \(error.localizedDescription)")
        }
    }

    func loadRootFolder() {
        loadFolder(from: rootFolder)
    }

    func loadSelectedFolder() {
        loadFolder(from: selectedFolder)
    }

    func loadFolder(from folder: Folder?) {
        resetFolder()

        guard let rootURL else { return }
        guard let folder else { return }
        do {
            try withSecurityScope(rootURL) {
                folderFileURLs = try TextFileURLCollector().collectShallowly(from: folder.url)
                folderFileURLs?.sort { $0.lastPathComponent < $1.lastPathComponent }
                selectedFolder = folder
            }
        } catch {
            activeError = ActiveError(message: error.localizedDescription)
            isShowActiveError = true
            log("load folder: \(error.localizedDescription)")
        }
    }

    func loadFolderAndFile(from url: URL?) {
        resetFolder()

        guard let rootFolder else { return }
        guard let url else { return }

        let folderURL = url.deletingLastPathComponent()
        guard let folder = rootFolder.findChild(with: folderURL) else { return }
        loadFolder(from: folder)

        if let folderFileURLs, folderFileURLs.contains(url) {
            loadFile(from: url)
        }
    }

    func loadSelectedFile() {
        loadFile(from: selectedFileURL)
    }

    func loadFile(from url: URL?) {
        resetFile()

        guard let rootURL else { return }
        guard let url else { return }
        let fileName = url.lastPathComponent
        do {
            try withSecurityScope(rootURL) {
                let buffer = TextBuffer(url: url)
                try buffer.loadContent()
                self.buffer = buffer

                self.fileMonitor = FileMonitor()
                fileMonitor?.startMonitoring(url) { [weak self] _ in
                    guard let self else { return }
                    self.loadFile(from: url)
                }

                selectedFileURL = url
                log("load file: file loaded, \(fileName)")
            }
        } catch {
            activeError = ActiveError(message: error.localizedDescription)
            isShowActiveError = true
            log("load file: \(error.localizedDescription)")
        }
    }

    func saveFileIfEdited() {
        guard let buffer, buffer.isEdited, !buffer.hasSaveError else { return }
        saveFile()
    }

    func saveFile() {
        guard let rootURL else { return }
        guard let buffer else { return }
        let fileName = buffer.url.lastPathComponent
        do {
            try withSecurityScope(rootURL) {
                try fileMonitor?.disableMonitoringWhile {
                    try buffer.saveContent()
                }
            }
            log("save file: file saved, \(fileName)")
        } catch {
            activeError = ActiveError(message: error.localizedDescription)
            isShowActiveError = true
            log("save file: \(error.localizedDescription)")
        }
    }
}

