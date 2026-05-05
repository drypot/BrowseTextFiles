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
    private(set) var rootFolder: FolderItem?
    private(set) var selectedFolder: FolderItem?
    private(set) var expandedFolders: Set<URL> = []

    private(set) var fileList: [FileItem]?
    private(set) var selectedFile: FileItem?

    private(set) var fileBuffer: FileBuffer?
    private var fileMonitor: FileMonitor?

    var isShowNewFileView = false

    var isShowSearchView = false
    var searchText = ""
    private(set) var isSearching = false
    private(set) var searchResults: [SearchResult]?

    var activeError: ActiveError?
    var isShowActiveError = false

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

    func resetFolderTree() {
        rootFolder = nil
        selectedFolder = nil
        //expandedFolders.removeAll()
    }

    func loadFolderTree(from rootURL: URL) {
        resetFolderTree()
        do {
            try withSecurityScope(rootURL) {
                rootFolder = try FolderTreeBuilder().buildTree(from: rootURL)
                expandFolder(for: rootURL)
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

    func selectedFolderBinding() -> Binding<FolderItem?> {
        Binding<FolderItem?>(
            get: { self.selectedFolder },
            set: { self.updateSelectedFolder(to: $0) }
        )
    }

    func updateSelectedFolder(to folder: FolderItem?) {
        if selectedFolder == folder { return }

        selectedFolder = folder
        if let folder {
            loadFileList(from: folder.url)
        } else {
            resetFileList()
        }
    }

    func updateSelectedFolderToFolder(with url: URL) {
        let folder = rootFolder?.findFolder(with: url)
        updateSelectedFolder(to: folder)
    }

    func updateSelectedFolderToRoot() {
        updateSelectedFolder(to: rootFolder)
    }

    func moveDownSelectedFolder() {
        guard let rootFolder else { return }
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

        guard let result = findNext(from: rootFolder) else { return }
        updateSelectedFolder(to: result)
    }

    func moveUpSelectedFolder() {
        guard let rootFolder else { return }
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

        guard let result = findPrevious(from: rootFolder) else { return }
        updateSelectedFolder(to: result)
    }

    func moveToParentFolder() {
        guard let rootFolder else { return }
        guard let selectedFolder else { return }

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

        if let result = findParent(from: rootFolder, parent: nil) {
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
                    self.expandFolder(for: url)
                } else {
                    self.collapseFolder(for: url)
                }
            }
        )
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

    func collapseSelectedFolder() {
        guard let selectedFolder else { return }

        if selectedFolder.hasChildren, isFolderExpanded(for: selectedFolder.url) {
            collapseFolder(for: selectedFolder.url)
        } else {
            moveToParentFolder()
        }
    }

    private func expandFolders(for folderURL: URL) {
        guard let rootURL else { return }
        let rootCount = rootURL.pathComponents.count
        let folderCount = folderURL.pathComponents.count
        let count = folderCount - rootCount

        var tmpURL = folderURL
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

    func loadFileList(from folderURL: URL) {
        resetFileList()
        do {
            guard let rootURL else { return }
            try withSecurityScope(rootURL) {
                fileList = try FileListBuilder().collectShallowly(from: folderURL) { contentType in
                    // contentType.conforms(to: .text)
                    return true
                }
                fileList?.sort { $0.name < $1.name }
            }
            log("load file list: \(folderURL.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("load file list: \(message)")
        }
    }

    func reloadFileList() {
        guard let selectedFolder else { return }
        loadFileList(from: selectedFolder.url)
    }

    func selectedFileBinding() -> Binding<FileItem?> {
        return Binding<FileItem?>(
            get: { self.selectedFile },
            set: { self.updateSelectedFile(with: $0) }
        )
    }

    func updateSelectedFile(with fileItem: FileItem?) {
        selectedFile = fileItem
        if let fileItem {
            loadFile(from: fileItem.url)
        } else {
            resetFileBuffer()
        }
    }

    private func updateSelectedFile(withChecked url: URL) {
        let first = fileList?.first { $0.url == url }
        if let first {
            updateSelectedFile(with: first)
        } else {
            updateSelectedFile(with: nil)
        }
    }

    func moveDownSelectedFile() {
        guard let fileList else { return }
        var previous: FileItem?
        var result: FileItem?

        for item in fileList {
            if previous == selectedFile {
                result = item
                break
            }
            previous = item
        }

        if let result {
            updateSelectedFile(with: result)
        }
    }

    func moveUpSelectedFile() {
        guard let fileList else { return }
        var previous: FileItem?
        var result: FileItem?

        for item in fileList {
            if item == selectedFile {
                result = previous
                break
            }
            previous = item
        }

        if let result {
            updateSelectedFile(with: result)
        }
    }

    // MARK: - Buffer

    func resetFileBuffer() {
        saveFileIfEdited()
        if isShowActiveError { return }

        fileBuffer = nil
        fileMonitor = nil
    }

    func loadFile(from url: URL) {
        saveFileIfEdited()
        if isShowActiveError { return }

        isShowSearchView = false
        loadFileLoop(from: url)
    }

    private func loadFileLoop(from url: URL) {
        fileBuffer = FileBuffer(from: url)
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

    func loadFileAndSetupEnvironment(for url: URL) {
        let folderURL = url.deletingLastPathComponent()

        updateSelectedFolderToFolder(with: folderURL)
        if isShowActiveError { return }

        if selectedFolder != nil {
            updateSelectedFile(withChecked: url)
            expandFolders(for: folderURL)
        } else {
            updateSelectedFolder(to: rootFolder)
        }
    }

    func loadSearchedFile(_ url: URL) {
        loadFileAndSetupEnvironment(for: url)

        // guard let fileBuffer else { return }

        // 파일 내용중 '학생'을 검색해서 커서를 이동시키는데
        // 어떨 때는 정상으로 이동하다가
        // 파일 뒤에 내용이 별로 없으면 커서가 학생으로 가지 않고 화일 끝으로 가는 현상이 있었다.
        // 원인은 모르겠다.

        // Swift String 과 NSString 차이 때문에 발생하는 것 같진 않았다.
        // 이리저리 테스트하다가 테스트 코드는 일단 다 삭제.

        // 검색 단어로 커서를 옮기는 아래 기능은
        // 될 때가 있고 안 될 때가 있어서 일단 사용중지.

        // let range = fileBuffer.text.range(of: searchText)
        // if let range {
        //     fileBuffer.selection = TextSelection(insertionPoint: range.lowerBound)
        //     log("range: \(range)")
        // }

        let findPasteboard = NSPasteboard(name: .find)
        findPasteboard.declareTypes([.string], owner: nil)
        findPasteboard.setString(searchText, forType: .string)
    }


    // MARK: - Reload

    func reloadAll() {
        saveFileIfEdited()
        if isShowActiveError { return }

        let folderURL = fileBuffer?.url.deletingLastPathComponent()
        let fileURL = fileBuffer?.url

        reloadFolderTree()
        if isShowActiveError { return }

        guard let folderURL else { return }
        updateSelectedFolderToFolder(with: folderURL)

        guard let fileURL else { return }
        updateSelectedFile(withChecked: fileURL)

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
        isShowNewFileView = true
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
                loadFileAndSetupEnvironment(for: newFileURL)
            }
        } catch {
            let message = error.localizedDescription
            activeError = ActiveError(message: message)
            isShowActiveError = true
            log("new file: \(message)")
        }
    }

    // MARK: - Search

    func toggleSearchView() {
        if !isRootReady { return }
        isShowSearchView.toggle()
    }

    func hideSearchView() {
        if !isRootReady { return }
        isShowSearchView = false
    }

    func showSearchView() {
        if !isRootReady { return }
        isShowSearchView = true
    }

    func startSearch() {
        guard let rootURL else { return }
        if isSearching { return }
        if searchText.isEmpty { return }

        searchResults = []
        isSearching = true
        log("start search: \"\(searchText)\"")

        Task {
            do {
                searchResults = try await searchParallel(rootURL: rootURL, searchText: searchText)
                isSearching = false
                log("start search: found \(searchResults?.count ?? 0) files")
            } catch {
                let message = error.localizedDescription
                activeError = ActiveError(message: message)
                isShowActiveError = true
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
                        let title = String(fileItem.url.path(percentEncoded: false).dropFirst(basePathLength))
                        return SearchResult(url: fileItem.url, title: title, lines: lines)
                    } else {
                        return nil
                    }
                }
            }
            var results: [SearchResult] = []
            while let result = try await group.next() {
                guard let result else { continue }
                print("\(result)")
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
