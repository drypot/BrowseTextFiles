//
//  FileBrowserStatus.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers
import MyLibrary

@Observable
final class FileBrowserStatus {
    private var rootFolder: Folder?
    public var selectedFolder: Folder?

    private(set) var fileURLs: [URL]?
    public var selectedFileURL: URL?

    private(set) var fileBuffer: FileBuffer?
    private var fileMonitor: FileMonitor?

    var activeError: ActiveError?
    var isShowActiveError = false

    var isShowNewFile = false

    private let log = LogStore.shared.log

    // MARK: - Folder Tree

    var isRootReady: Bool {
        rootFolder != nil
    }

    var rootURL: URL? {
        rootFolder?.url
    }

    var rootName: String? {
        rootFolder?.name
    }

    var foldersForList: [Folder] {
        if let rootFolder {
            [rootFolder]
        } else {
            []
        }
    }

    func resetFolderTree() {
        rootFolder = nil
        selectedFolder = nil
    }

    func loadFolderTree(from rootURL: URL) {
        resetFolderTree()
        do {
            try withSecurityScope(rootURL) {
                rootFolder = try FolderTreeBuilder().build(from: rootURL)
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
        if let rootURL {
            loadFolderTree(from: rootURL)
        } else {
            resetFolderTree()
        }
    }

    func selectedFolderBinding() -> Binding<Folder?> {
        Binding<Folder?>(
            get: { self.selectedFolder },
            set: { self.updateSelectedFolder(to: $0) }
        )
    }

    private func updateSelectedFolder(to folder: Folder?) {
        selectedFolder = folder
        if let folder {
            loadFileList(from: folder.url)
        } else {
            resetFileList()
        }
    }

    private func updateSelectedFolder(with url: URL) {
        let folder = rootFolder?.findFolder(with: url)
        updateSelectedFolder(to: folder)
    }

    func updateSelectedFolderToRoot() {
        updateSelectedFolder(to: rootFolder)
    }

    // MARK: - File List

    var fileURLsForList: [URL] {
        if let urls = fileURLs {
            urls
        } else {
            []
        }
    }

    func resetFileList() {
        fileURLs = nil
        selectedFileURL = nil
    }

    func loadFileList(from folderURL: URL) {
        resetFileList()
        do {
            guard let rootURL else { return }
            try withSecurityScope(rootURL) {
                fileURLs = try FileURLCollector().collectShallowly(from: folderURL) { contentType in
                    // contentType.conforms(to: .text)
                    return true
                }
                fileURLs?.sort { $0.lastPathComponent < $1.lastPathComponent }
            }
            log("load folder: \(folderURL.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("load folder: \(message)")
        }
    }

    func selectedFileURLBinding() -> Binding<URL?> {
        return Binding<URL?>(
            get: { self.selectedFileURL },
            set: { self.updateSelectedFileURL(with: $0) }
        )
    }

    private func updateSelectedFileURL(with url: URL?) {
        selectedFileURL = url
        if let url {
            loadFile(from: url)
        } else {
            resetFileBuffer()
        }
    }

    private func updateSelectedFileURL(withChecked url: URL) {
        if fileURLs?.contains(url) == true {
            updateSelectedFileURL(with: url)
        } else {
            updateSelectedFileURL(with: nil)
        }
    }

    // MARK: - Buffer

    var isBufferReady: Bool {
        fileBuffer != nil
    }

    func resetFileBuffer() {
        saveFileIfEdited()
        if isShowActiveError { return }

        fileBuffer = nil
        fileMonitor = nil
    }

    func loadFile(from url: URL) {
        saveFileIfEdited()
        if isShowActiveError { return }

        loadFileLoop(from: url)
    }

    private func loadFileLoop(from url: URL) {
        fileBuffer = FileBuffer(url: url)
        fileMonitor = nil
        do {
            guard let rootURL else { return }
            try withSecurityScope(rootURL) {
                try fileBuffer!.loadContent()

                fileMonitor = FileMonitor()
                fileMonitor!.startMonitoring(url) { [weak self] _ in
                    guard let self else { return }
                    self.loadFileLoop(from: url)
                }

                log("load file: \(url.lastPathComponent)")
            }
        } catch {
            let message = error.localizedDescription
            fileBuffer!.loadError = message
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("load file: \(message)")
        }
    }

    // MARK: - Load File

    func updateSelectedFolderAndFile(with url: URL) {
        let folderURL = url.deletingLastPathComponent()

        updateSelectedFolder(with: folderURL)
        if isShowActiveError { return }

        if selectedFolder != nil {
            updateSelectedFileURL(withChecked: url)
        } else {
            updateSelectedFolder(to: rootFolder)
        }
    }

    // MARK: - Reload

    func reloadAll() {
        saveFileIfEdited()
        if isShowActiveError { return }

        let folderURL = selectedFolder?.url
        let fileURL = fileBuffer?.url

        reloadFolderTree()
        if isShowActiveError { return }

        guard let folderURL else { return }
        updateSelectedFolder(with: folderURL)

        guard let fileURL else { return }
        updateSelectedFileURL(withChecked: fileURL)

        log("reload all:")
    }

    // MARK: - Save File

    func saveFileIfEdited() {
        guard let fileBuffer, fileBuffer.isEdited, !fileBuffer.hasSaveError else { return }
        saveFile()
    }

    func saveFile() {
        guard let fileBuffer else { return }
        if fileBuffer.loadError != nil { return }
        do {
            guard let rootURL else { return }
            try withSecurityScope(rootURL) {
                try fileMonitor?.disableMonitoringWhile {
                    try fileBuffer.saveContent()
                }
            }
            log("save file: \(fileBuffer.url.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("save file: \(message)")
        }
    }

    // MARK: - New File

    func showNewFileForm() {
        saveFileIfEdited()
        if isShowActiveError { return }

        if selectedFolder != nil { return }
        isShowNewFile = true
    }
    
    func makeNewFile(path: String) {
        do {
            guard let rootURL else { return }
            let newFileURL = rootURL.appending(component: path)
            let fileManager = FileManager.default
            try withSecurityScope(rootURL) {
                if fileManager.fileExists(atPath: newFileURL.path) {
                    // do nothing
                } else {
                    let folderURL = newFileURL.deletingLastPathComponent()
                    if fileManager.fileExists(atPath: folderURL.path) {
                        // do nothing
                    } else {
                        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                        reloadFolderTree()
                    }
                    try "".write(to: newFileURL, atomically: true, encoding: .utf8)
                    log("new file: \(path)")
                }
                updateSelectedFolderAndFile(with: newFileURL)
            }
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("new file: \(message)")
        }
    }
}



