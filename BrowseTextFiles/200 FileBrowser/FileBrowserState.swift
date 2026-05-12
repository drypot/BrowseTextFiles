//
//  FileBrowserState.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers
import MyLibrary

extension FocusedValues {
    @Entry var currentFileBrowserState: FileBrowserState? = nil
}

@Observable
final class FileBrowserState {
    let id = UUID()

    private(set) var rootFolder: FolderItem?
    private(set) var selectedFolder: FolderItem?
    private(set) var expandedFolders: Set<URL> = []

    private(set) var fileList: [FileItem]?
    private(set) var selectedFile: FileItem?

    private(set) var fileBuffer: TextBuffer?

    var isShowNewFileView = false

    var searchText = ""
    private(set) var isSearching = false
    private(set) var searchResults: [SearchResult]?

    var alertMessage: String?
    var hasAlertMessage = false

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

    var debuggingName: String {
        rootName ?? "nil"
    }

    var hasFileBufferAlertMessage: Bool {
        get { fileBuffer?.hasAlertMessage ?? false }
        set { fileBuffer?.hasAlertMessage = newValue }
    }

    func resetFolderTree() {
        rootFolder = nil
        selectedFolder = nil
        //expandedFolders.removeAll()
    }

    func updateFolderTree(from url: URL) {
        resetFolderTree()
        do {
            try withSecurityScope(url) {
                rootFolder = try FolderTreeBuilder().buildTree(from: url)
                selectedFolder = rootFolder
                expandFolder(for: url)
            }
            log("load root: \(url.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            alertMessage = message
            hasAlertMessage = true
            log("load root: \(message)")
        }
    }

    func reloadFolderTree() {
        guard let rootURL else {
            resetFolderTree()
            return
        }

        let selectedFolderURL = selectedFolder?.url

        updateFolderTree(from: rootURL)
        if let selectedFolderURL {
            updateSelectedFolder(from: selectedFolderURL)
        }
    }

    // MARK: - Selected Folder

    func selectedFolderBinding() -> Binding<FolderItem?> {
        Binding<FolderItem?>(
            get: { self.selectedFolder },
            set: {
                self.updateSelectedFolder(to: $0)
                self.updateFileListFromSelectedFolder()
            }
        )
    }

    func updateSelectedFolder(to folder: FolderItem?) {
        selectedFolder = folder
    }

    func updateSelectedFolder(from url: URL) {
        if let folder = rootFolder?.findFolder(with: url) {
            updateSelectedFolder(to: folder)
        }
    }

    func updateSelectedFolderToRoot() {
        updateSelectedFolder(to: rootFolder)
    }

    func moveSelectedFolderDown() -> Bool {
        guard let rootFolder else { return false }
        var previous: FolderItem?

        func findNext(from current: FolderItem) -> FolderItem? {
            if previous == selectedFolder {
                return current
            }
            previous = current

            if let children = current.children, isFolderExpanded(for: current.url) {
                for child in children {
                    if let result = findNext(from: child) {
                        return result
                    }
                }
            }

            return nil
        }

        guard let result = findNext(from: rootFolder) else { return false }
        updateSelectedFolder(to: result)
        return true
    }

    func moveSelectedFolderUp() -> Bool {
        guard let rootFolder else { return false }
        var previous: FolderItem?

        func findPrevious(from current: FolderItem) -> FolderItem? {
            if current == selectedFolder {
                return previous
            }
            previous = current

            if let children = current.children, isFolderExpanded(for: current.url) {
                for child in children {
                    if let result = findPrevious(from: child) {
                        return result
                    }
                }
            }

            return nil
        }

        guard let result = findPrevious(from: rootFolder) else { return false }
        updateSelectedFolder(to: result)
        return true
    }

    func moveSelectedFolderToParent() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolder else { return false }

        func findParent(from current: FolderItem, parent: FolderItem?) -> FolderItem? {
            if current == selectedFolder {
                return parent
            }

            if let children = current.children, isFolderExpanded(for: current.url) {
                for child in children {
                    if let result = findParent(from: child, parent: current) {
                        return result
                    }
                }
            }

            return nil
        }

        guard let result = findParent(from: rootFolder, parent: nil) else { return false }
        updateSelectedFolder(to: result)
        return true
    }

    // MARK: - Folder Folding

    func isFolderExpanded(for url: URL) -> Bool {
        expandedFolders.contains(url)
    }

    func expandFolder(for url: URL) {
        expandedFolders.insert(url)
    }

    func collapseFolder(for url: URL) {
        expandedFolders.remove(url)
    }

    func toggleFolder(for url: URL) {
        if isFolderExpanded(for: url) {
            collapseFolder(for: url)
        } else {
            expandFolder(for: url)
        }
    }

    func expandSelectedFolder() {
        guard let selectedFolder else { return }
        if selectedFolder.hasChildren {
            expandFolder(for: selectedFolder.url)
        }
    }

    func collapseSelectedFolder() -> Bool {
        guard let selectedFolder else { return false }
        if selectedFolder.hasChildren, isFolderExpanded(for: selectedFolder.url) {
            collapseFolder(for: selectedFolder.url)
        } else {
            return moveSelectedFolderToParent()
        }
        return false
    }

    private func expandFolders(for url: URL) {
        guard let rootURL else { return }
        let rootCount = rootURL.pathComponents.count
        let urlCount = url.pathComponents.count
        let count = urlCount - rootCount

        var tmpURL = url
        for _ in 0 ..< count {
            expandFolder(for: tmpURL)
            tmpURL = tmpURL.deletingLastPathComponent()
        }
    }

    // MARK: - File List

    func resetFileList() {
        fileList = nil
        selectedFile = nil
    }

    func updateFileList(from url: URL) {
        guard let rootURL else { return }

        resetFileList()
        do {
            try withSecurityScope(rootURL) {
                fileList = try FileListBuilder().collectShallowly(from: url) { contentType in
                    // contentType.conforms(to: .text)
                    return true
                }
                fileList?.sort { $0.name < $1.name }
            }
            log("load list: \(url.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            alertMessage = message
            hasAlertMessage = true
            log("load list: \(message)")
        }
    }

    func updateFileListFromSelectedFolder() {
        if let folder = selectedFolder {
            updateFileList(from: folder.url)
        } else {
            resetFileList()
        }
    }

    func selectedFileBinding() -> Binding<FileItem?> {
        return Binding<FileItem?>(
            get: { self.selectedFile },
            set: {
                self.updateSelectedFile(to: $0)
                self.updateFileBufferFromSelectedFile()
            }
        )
    }

    func updateSelectedFile(to fileItem: FileItem?) {
        selectedFile = fileItem
    }

    func updateSelectedFile(from url: URL) {
        selectedFile = fileList?.first { $0.url == url }
    }

    func moveSelectedFileDown() -> Bool {
        guard let fileList else { return false }
        var previous: FileItem?

        for item in fileList {
            if previous == selectedFile {
                updateSelectedFile(to: item)
                return true
            }
            previous = item
        }

        return false
    }

    func moveSelectedFileUp() -> Bool {
        guard let fileList else { return false }
        var previous: FileItem?

        for item in fileList {
            if item == selectedFile {
                guard let previous else { return false }
                updateSelectedFile(to: previous)
                return true
            }
            previous = item
        }

        return false
    }

    // MARK: - TextBuffer

    func resetFileBuffer() {
        guard autoSaveFileBuffer() else { return }
        fileBuffer?.invalidate()
        fileBuffer = nil
        log("reset buffer:")
    }

    func updateFileBuffer(from url: URL) {
        guard let rootURL else { return }
        guard autoSaveFileBuffer() else { return }

        fileBuffer = TextBuffer(from: url, rootURL: rootURL)
        guard let fileBuffer else { return }

        log("create buffer: \(fileBuffer.name)")
        fileBuffer.loadOriginalText()
    }

    func updateFileBufferFromSelectedFile() {
        if let fileItem = selectedFile {
            updateFileBuffer(from: fileItem.url)
        } else {
            resetFileBuffer()
        }
    }

    private func autoSaveFileBuffer() -> Bool {
        guard let fileBuffer else { return true }
        fileBuffer.autoSaveTextView()
        return !fileBuffer.hasAlertMessage
    }

    func saveFile() {
        guard let fileBuffer else { return }
        fileBuffer.saveTextView()
    }

    // MARK: - Update All

    func updateAll(fromRootURL rootURL: URL, fileURL: URL?) {
        updateFolderTree(from: rootURL)
        if !isRootReady { return }

        if let fileURL {
            updateAll(fromFileURL: fileURL)
        } else {
            updateSelectedFolderToRoot()
            updateFileListFromSelectedFolder()
        }
    }

    func updateAll(fromFileURL fileURL: URL) {
        let folderURL = fileURL.deletingLastPathComponent()

        updateSelectedFolder(from: folderURL)
        updateFileList(from: folderURL)
        if hasAlertMessage { return }

        if fileList != nil {
            updateSelectedFile(from: fileURL)
            updateFileBuffer(from: fileURL)
            expandFolders(for: folderURL)
        }
    }

    func reloadAll() {
        guard autoSaveFileBuffer() else { return }

        let fileURL = fileBuffer?.url

        reloadFolderTree()
        if hasAlertMessage { return }

        if let fileURL {
            updateAll(fromFileURL: fileURL)
        }

        log("reload all:")
    }

    // MARK: - New File

    func showNewFileView() {
        guard autoSaveFileBuffer() else { return }

        if selectedFolder == nil {
            alertMessage = "Select folder first."
            hasAlertMessage = true
        } else {
            isShowNewFileView = true
        }
    }
    
    func makeNewFile(path: String) {
        let fileManager = FileManager.default
        guard let rootURL else { return }

        do {
            let newFileURL = rootURL.appending(component: path)
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
                updateAll(fromFileURL: newFileURL)
            }
        } catch {
            let message = error.localizedDescription
            alertMessage = message
            hasAlertMessage = true
            log("new file: \(message)")
        }
    }

    // MARK: - Search

    func startSearch() {
        guard let rootURL else { return }
        if isSearching { return }
        if searchText.isEmpty { return }

        searchResults = []
        isSearching = true
        log("start search: \"\(searchText)\"")

        let pasteboard = NSPasteboard(name: .find)
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(searchText, forType: .string)

        // textView 에 FindBar 를 띄운다.
        let dummyItem = NSMenuItem()
        dummyItem.tag = Int(NSFindPanelAction.showFindPanel.rawValue)
        fileBuffer?.textView?.performTextFinderAction(dummyItem)

        Task {
            do {
                searchResults = try await searchParallel(rootURL: rootURL, searchText: searchText)
                isSearching = false
                log("start search: found \(searchResults?.count ?? 0) files")
            } catch {
                let message = error.localizedDescription
                alertMessage = message
                hasAlertMessage = true
                log("start search: \(message)")
            }
        }
    }

    @concurrent
    public func searchParallel(rootURL: URL, searchText: String) async throws -> [SearchResult] {
        let isAccessing = rootURL.startAccessingSecurityScopedResource()
        defer {
            if isAccessing { rootURL.stopAccessingSecurityScopedResource() }
        }

        let basePath = rootURL.path(percentEncoded: false)
        let basePathLength = basePath.count

        return try await withThrowingTaskGroup(of: SearchResult?.self) { group in
            for fileItem in try FileListBuilder().collectRecursively(from: rootURL) {
                group.addTask(priority: .userInitiated) {
                    let lines = try Self.filterLines(from: fileItem.url, searchText: searchText)
                    if fileItem.name.contains(searchText) || lines.count > 0 {
                        let title = String(fileItem.url.path(percentEncoded: false).dropFirst(basePathLength)).precomposedStringWithCanonicalMapping
                        return SearchResult(url: fileItem.url, title: title, lines: lines)
                    } else {
                        return nil
                    }
                }
            }
            var results: [SearchResult] = []
            while let result = try await group.next() {
                guard let result else { continue }
                results.append(result)
            }
            return results.sorted { $0.title < $1.title }
        }
    }

    nonisolated private static func filterLines(from url: URL, searchText: String) throws -> [SearchResult.Line] {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { try? fileHandle.close() }

        var buffer = Data()
        var result: [SearchResult.Line] = []
//        var count = 0

        while let chunk = try fileHandle.read(upToCount: 4096), !chunk.isEmpty {
            buffer.append(chunk)
            while let range = buffer.range(of: Data([0x0A])) {
                let lineData = buffer.subdata(in: 0..<range.lowerBound)
                buffer.removeSubrange(0...range.lowerBound)
                let text = String(data: lineData, encoding: .utf8)
                if let text, text.contains(searchText) {
                    result.append(SearchResult.Line(text: text))
//                    count += 1
//                    if count >= 5 {
//                        return result
//                    }
                }
            }
        }

        // 마지막 줄 처리 (개행 없이 끝나는 경우)
        if let text = String(data: buffer, encoding: .utf8),
            text.contains(searchText) {
                result.append(SearchResult.Line(text: text))
        }

        return result
    }

    func clearSearchResult() {
        searchResults = nil
        searchText = ""
    }
}
