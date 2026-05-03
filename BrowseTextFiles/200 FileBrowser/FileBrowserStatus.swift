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
    private(set) var rootFolder: Folder?
    private(set) var selectedFolder: Folder?
    private(set) var expandedFolders: Set<URL> = []

    private(set) var fileURLs: [URL]?
    private(set) var selectedFileURL: URL?

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
        //expandedFolders.removeAll()
    }

    func loadFolderTree(from rootURL: URL) {
        resetFolderTree()
        do {
            try withSecurityScope(rootURL) {
                rootFolder = try FolderTreeBuilder().build(from: rootURL)
                expandFolder(with: rootURL)
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

    // MARK: - Folder Tree, Selection

    func selectedFolderBinding() -> Binding<Folder?> {
        Binding<Folder?>(
            get: { self.selectedFolder },
            set: { self.updateSelectedFolder(to: $0) }
        )
    }

    func updateSelectedFolder(to folder: Folder?) {
        if selectedFolder == folder { return }

        selectedFolder = folder
        if let folder {
            loadFileList(from: folder.url)
        } else {
            resetFileList()
        }
    }

    func updateSelectedFolder(with url: URL) {
        let folder = rootFolder?.findFolder(with: url)
        updateSelectedFolder(to: folder)
    }

    func updateSelectedFolderToRoot() {
        updateSelectedFolder(to: rootFolder)
    }

    func moveDownSelectedFolder() {
        guard let rootFolder else { return }
        var previous: Folder?

        func findNext(current: Folder) -> Folder? {
            if previous == selectedFolder {
                return current
            }
            previous = current

            if let children = current.folders, isFolderExpanded(for: current.url) {
                for child in children {
                    if let result = findNext(current: child) {
                        return result
                    }
                }
            }

            return nil
        }

        guard let result = findNext(current: rootFolder) else { return }
        updateSelectedFolder(to: result)
    }

    func moveUpSelectedFolder() {
        guard let rootFolder else { return }
        var previous: Folder?

        func findPrevious(current: Folder) -> Folder? {
            if current == selectedFolder {
                return previous
            }
            previous = current

            if let children = current.folders, isFolderExpanded(for: current.url) {
                for child in children {
                    if let result = findPrevious(current: child) {
                        return result
                    }
                }
            }

            return nil
        }

        guard let result = findPrevious(current: rootFolder) else { return }
        updateSelectedFolder(to: result)
    }

    func moveToParentFolder() {
        guard let rootFolder else { return }
        guard let selectedFolder else { return }

        func findParent(parent: Folder?, current: Folder) -> Folder? {
            if current == selectedFolder {
                return parent
            }

            if let children = current.folders, isFolderExpanded(for: current.url) {
                for child in children {
                    if let result = findParent(parent: current, current: child) {
                        return result
                    }
                }
            }

            return nil
        }

        if let result = findParent(parent: nil, current: rootFolder) {
            updateSelectedFolder(to: result)
        }
    }

    // MARK: - Folder Tree, Folding

    func isFolderExpanded(for url: URL) -> Bool {
        expandedFolders.contains(url)
    }

    func isFolderExpandedBinding(for url: URL) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.isFolderExpanded(for: url) },
            set: {
                if $0 {
                    self.expandFolder(with: url)
                } else {
                    self.collapseFolder(with: url)
                }
            }
        )
    }

    func expandFolder(with url: URL) {
        expandedFolders.insert(url)
    }

    func collapseFolder(with url: URL) {
        expandedFolders.remove(url)
    }

    func toggleFolder(with url: URL) {
        if isFolderExpanded(for: url) {
            collapseFolder(with: url)
        } else {
            expandFolder(with: url)
        }
    }

    func expandSelectedFolder() {
        guard let selectedFolder else { return }

        if selectedFolder.hasChildren {
            expandFolder(with: selectedFolder.url)
            print("do")
        }
    }

    func collapseSelectedFolder() {
        guard let selectedFolder else { return }

        if selectedFolder.hasChildren, isFolderExpanded(for: selectedFolder.url) {
            collapseFolder(with: selectedFolder.url)
        } else {
            moveToParentFolder()
        }
    }

    private func expandFolders(for folderURL: URL) {
        guard let rootURL else { return }
        let rootCount = rootURL.pathComponents.count
        let folderCount = folderURL.pathComponents.count
        let count = folderCount - rootCount

        var loopURL = folderURL
        for _ in 0 ..< count {
            expandFolder(with: loopURL)
            loopURL = loopURL.deletingLastPathComponent()
        }
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

    func reloadFileList() {
        guard let selectedFolder else { return }
        loadFileList(from: selectedFolder.url)
    }


    func selectedFileURLBinding() -> Binding<URL?> {
        return Binding<URL?>(
            get: { self.selectedFileURL },
            set: { self.updateSelectedFileURL(with: $0) }
        )
    }

    func updateSelectedFileURL(with url: URL?) {
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

    func moveDownSelectedFile() {
        guard let fileURLs else { return }
        var previous: URL?
        var result: URL?

        for item in fileURLs {
            if previous == selectedFileURL {
                result = item
                break
            }
            previous = item
        }

        if let result {
            updateSelectedFileURL(with: result)
        }
    }

    func moveUpSelectedFile() {
        guard let fileURLs else { return }
        var previous: URL?
        var result: URL?

        for item in fileURLs {
            if item == selectedFileURL {
                result = previous
                break
            }
            previous = item
        }

        if let result {
            updateSelectedFileURL(with: result)
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
            expandFolders(for: folderURL)
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

        if selectedFolder == nil { return }
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
                    reloadFileList()
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



