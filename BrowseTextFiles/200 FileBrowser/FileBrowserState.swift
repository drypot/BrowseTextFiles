//
//  FileBrowserState.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

@Observable
final class FileBrowserState {
    let id = UUID()

    private(set) var rootFolder: FolderForView?
    private(set) var expandedFolders: Set<URL> = []

    private(set) var selectedFolderID: FolderForView.ID?
    private(set) var selectedFolder: FolderForView?

    private(set) var renameFolderID: FolderForView.ID?
    var isShowRenameFolderView = false

    private(set) var fileList: [FileForView]?

    private(set) var selectedFileID: FileForView.ID?
    private(set) var selectedFile: FileForView?

    private(set) var renameFileID: FileForView.ID?
    var isShowRenameFileView = false

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

    func resetFolderTree() {
        rootFolder = nil
        deselectFolder()
        //expandedFolders.removeAll()
    }

    func updateFolderTree(from url: URL) {
        resetFolderTree()
        do {
            try withSecurityScope(url) {
                let folder = try FolderTreeBuilder().buildTree(from: url)
                rootFolder = folder
                selectFolder(folder)
                expandFolder(for: folder.url)
            }
            log("load root: \(url.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            log("load root: \(message)")
        }
    }

    func updateFolderTree() {
        guard let rootURL else {
            resetFolderTree()
            return
        }

        let selectedFolderURL = selectedFolder?.url

        updateFolderTree(from: rootURL)
        if let selectedFolderURL {
            selecteFolder(withURL: selectedFolderURL)
        }
    }

    // MARK: - Selected Folder

    //func selectedFolderIDBinding() -> Binding<FolderItem.ID?> {
    //    Binding<FolderItem.ID?>(
    //        get: { self.selectedFolderID },
    //        set: {
    //            self.updateSelectedFolderID(to: $0)
    //            self.updateFileListFromSelectedFolder()
    //        }
    //    )
    //}

    func findFolder(withID id: FolderForView.ID) -> FolderForView? {
        guard let rootFolder else { return nil }
        return rootFolder.findFolder(withID: id)
    }

    // URL 로 비교하면 패스 마지막에 "/" 이 붙으면서 비교가 귀찮아진다.
    // path 로 비교하면 마지막에 "/" 이 붙지 않는다;
    func findFolder(withPath path: String) -> FolderForView? {
        guard let rootFolder else { return nil }
        return rootFolder.findFolder(withPath: path)
    }

    func deselectFolder() {
        selectedFolderID = nil
        selectedFolder = nil
    }

    func selectFolder(_ folder: FolderForView?) {
        if let folder {
            selectedFolderID = folder.id
            selectedFolder = folder
        } else {
            deselectFolder()
        }
    }

    func selecteFolder(withID id: FolderForView.ID?) {
        if let id, let folder = findFolder(withID: id) {
            selectFolder(folder)
        } else {
            deselectFolder()
        }
    }

    func selecteFolder(withURL url: URL) {
        if let folder = findFolder(withPath: url.path) {
            selectFolder(folder)
        } else {
            deselectFolder()
        }
    }

    func selectedRootFolder() {
        selectFolder(rootFolder)
    }

    func selecteNextFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }
        var previous: FolderForView?

        func findNext(from current: FolderForView) -> FolderForView? {
            if previous?.id == selectedFolderID {
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

        guard let found = findNext(from: rootFolder) else { return false }
        selectFolder(found)
        return true
    }

    func selectePreviousFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }
        var previous: FolderForView?

        func findPrevious(from current: FolderForView) -> FolderForView? {
            if current.id == selectedFolderID {
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

        guard let found = findPrevious(from: rootFolder) else { return false }
        selectFolder(found)
        return true
    }

    func selecteParentFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }

        func findParent(from current: FolderForView, parent: FolderForView?) -> FolderForView? {
            if current.id == selectedFolderID {
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

        guard let found = findParent(from: rootFolder, parent: nil) else { return false }
        selectFolder(found)
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
            return selecteParentFolder()
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
        selecteFile(withID: nil)
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
            showAlert(message)
            log("load list: \(message)")
        }
    }

    func updateFileListFromSelectedFolder() {
        if let selectedFolder {
            updateFileList(from: selectedFolder.url)
        } else {
            resetFileList()
        }
    }

    // MARK: - Selected File

    func findFile(with id: FileForView.ID) -> FileForView? {
        guard let fileList else { return nil }
        return fileList.first { $0.id ==  id }
    }

    func deselecteFile() {
        selectedFileID = nil
        selectedFile = nil
    }

    func selecteFile(_ fileItem: FileForView?) {
        if let fileItem {
            selectedFileID = fileItem.id
            selectedFile = fileItem
        } else {
            deselecteFile()
        }
    }

    func selecteFile(withID id: FileForView.ID?) {
        if let fileList, let file = fileList.first(where: { $0.id ==  id }) {
            selectedFileID = file.id
            selectedFile = file
        } else {
            deselecteFile()
        }
    }

    func selecteFile(withURL url: URL) {
        if let fileList, let file = fileList.first(where: { $0.url ==  url }) {
            selectedFileID = file.id
            selectedFile = file
        } else {
            deselecteFile()
        }
    }

    func selecteNextFile() -> Bool {
        guard let fileList else { return false }
        guard let selectedFileID else { return false }
        var previous: FileForView?

        for item in fileList {
            if previous?.id == selectedFileID {
                selecteFile(item)
                return true
            }
            previous = item
        }

        return false
    }

    func selectePreviousFile() -> Bool {
        guard let fileList else { return false }
        guard let selectedFileID else { return false }
        var previous: FileForView?

        for item in fileList {
            if item.id == selectedFileID {
                guard let previous else { return false }
                selecteFile(previous)
                return true
            }
            previous = item
        }

        return false
    }

    // MARK: - TextBuffer

    var hasFileBufferAlertMessage: Bool {
        get { fileBuffer?.hasAlertMessage ?? false }
        set { fileBuffer?.hasAlertMessage = newValue }
    }

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
        if let selectedFile {
            updateFileBuffer(from: selectedFile.url)
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
            selectedRootFolder()
            updateFileListFromSelectedFolder()
        }
    }

    func updateAll(fromFileURL fileURL: URL) {
        let folderURL = fileURL.deletingLastPathComponent()

        selecteFolder(withURL: folderURL)
        updateFileList(from: folderURL)
        if hasAlertMessage { return }

        if fileList != nil {
            selecteFile(withURL: fileURL)
            updateFileBuffer(from: fileURL)
            expandFolders(for: folderURL)
        }
    }

    func reloadAll() {
        guard autoSaveFileBuffer() else { return }

        let fileURL = fileBuffer?.url

        updateFolderTree()
        if hasAlertMessage { return }

        if let fileURL {
            updateAll(fromFileURL: fileURL)
        }

        log("reload all:")
    }

    // MARK: - New File

    func showNewFileView() {
        guard autoSaveFileBuffer() else { return }

        if selectedFolderID == nil {
            showAlert("Select folder first.")
        } else {
            isShowNewFileView = true
        }
    }
    
    func makeNewFile(path: String) {
        do {
            guard let rootURL else { return }
            let fileManager = FileManager.default
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
                        updateFolderTree()
                    }
                    try "".write(to: newFileURL, atomically: true, encoding: .utf8)
                    log("new file: \(path)")
                }
                updateAll(fromFileURL: newFileURL)
            }
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            log("new file: \(message)")
        }
    }

    // MARK: - Rename

    func showRenameFile(id: FileForView.ID) {
        renameFileID = id
        isShowRenameFileView = true
    }

    func renameFile(from orgURL: URL, to newURL: URL) {
        do {
            guard let rootURL else { return }
            let fileManager = FileManager.default
            let selectedFileURL = selectedFile?.url
            let shouldUpdateFileBuffer = selectedFileURL == orgURL
            if shouldUpdateFileBuffer {
                resetFileBuffer()
            }
            try withSecurityScope(rootURL) {
                try fileManager.moveItem(at: orgURL, to: newURL)
            }
            updateFileListFromSelectedFolder()
            if shouldUpdateFileBuffer {
                selecteFile(withURL: newURL)
                updateFileBufferFromSelectedFile()
            } else if let selectedFileURL {
                selecteFile(withURL: selectedFileURL)
            }
            log("rename from: \(orgURL.relativePath)")
            log("rename to: \(newURL.relativePath)")
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            log("rename file: \(message)")
        }
    }

    func showRenameFolder(id: FolderForView.ID) {
        renameFolderID = id
        isShowRenameFolderView = true
    }

    func renameFolder(from orgURL: URL, to newURL: URL) {
        do {
            guard let rootURL else { return }
            let fileManager = FileManager.default

            let selectedFolderURL = selectedFolder?.url
            let shouldUpdateSelectedFolder = if let selectedFolderURL {
                selectedFolderURL.isChildOrEqual(to: orgURL)
            } else {
                false
            }

            // selectedFile 이 nil 이지만,
            // fileBuffer 가 nil 이 아닌 경우가 있다;
            let fileBufferURL = fileBuffer?.url
            let shouldUpdateFileBuffer = if let fileBufferURL {
                fileBufferURL.isChild(of: orgURL)
            } else {
                false
            }

            if shouldUpdateFileBuffer {
                resetFileBuffer()
            }
            try withSecurityScope(rootURL) {
                try fileManager.moveItem(at: orgURL, to: newURL)
            }
            if shouldUpdateSelectedFolder {
                updateFolderTree(from: rootURL)
                selecteFolder(withURL: newURL)
                expandFolders(for: newURL)
                updateFileListFromSelectedFolder()
            } else {
                updateFolderTree()
            }
            log("rename from: \(orgURL.relativePath)")
            log("rename to: \(newURL.relativePath)")
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            log("rename folder: \(message)")
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
        // 오바 같아서 comment out;
        
        // let dummyItem = NSMenuItem()
        // dummyItem.tag = Int(NSFindPanelAction.showFindPanel.rawValue)
        // fileBuffer?.textView?.performTextFinderAction(dummyItem)

        Task {
            do {
                searchResults = try await searchParallel(rootURL: rootURL, searchText: searchText)
                isSearching = false
                log("start search: found \(searchResults?.count ?? 0) files")
            } catch {
                let message = error.localizedDescription
                showAlert(message)
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

    // MARK: - Alert

    func showAlert(_ message: String) {
        alertMessage = message
        hasAlertMessage = true
    }
}
