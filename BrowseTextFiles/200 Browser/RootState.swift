//
//  RootState.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

@Observable
final class RootState: Identifiable {

    // MARK: - New File Sheet

    struct NewFileContext {
        let folderURL: URL
    }

    @ObservationIgnored var newFileContext: NewFileContext?

    var isNewFilePresented = false

    // MARK: - New File with Template Sheet

    struct NewFileWithTemplateContext {
        let folderRelativePath: String
    }

    @ObservationIgnored var newFileWithTemplateContext: NewFileWithTemplateContext?

    var isNewFileWithTemplatePresented = false

    // MARK: - New Folder Sheet

    struct NewFolderContext {
        let folderURL: URL
    }

    @ObservationIgnored var newFolderContext: NewFolderContext?

    var isNewFolderPresented = false

    // MARK: - Rename File Sheet

    struct RenameFileContext {
        let oldURL: URL
    }

    @ObservationIgnored var renameFileContext: RenameFileContext?

    var isRenameFilePresented = false

    // MARK: - Rename Folder Sheet

    struct RenameFolderContext {
        let oldURL: URL
    }

    @ObservationIgnored var renameFolderContext: RenameFolderContext?

    var isRenameFolderPresented = false

    // MARK: - States

    @ObservationIgnored var appState: AppState?
    @ObservationIgnored var browserState: BrowserState
    @ObservationIgnored var folderListState: FolderListState
    @ObservationIgnored var fileListState: FileListState
    @ObservationIgnored var searchState: SearchState
    @ObservationIgnored var historyState: HistoryState
    @ObservationIgnored var editorState: EditorState

    init() {
        browserState = BrowserState()
        folderListState = FolderListState(browserState: browserState)
        fileListState = FileListState(browserState: browserState)
        searchState = SearchState(browserState: browserState)
        historyState = HistoryState()
        editorState = EditorState(browserState: browserState)

        printLog("init browser state: \(id)")
    }

    func releaseResource() {
        consoleLog("release browser resource:")
        browserState.releaseResource()
    }

    func configure(with rootURL: URL, appState: AppState) {
        consoleLog("configure root state: \(rootURL.path(percentEncoded: false))")
        self.appState = appState
        browserState.configure(with: rootURL)
        folderListState.reloadFolderTree()
        browserState.selectedFolderURL = rootURL
        appState.addRecentDocumentURL(rootURL)
    }

    // MARK: - Reload

    func reload() {
        consoleLog("reload:")
        folderListState.reloadFolderTree()
        fileListState.loadFileList()
    }

    // MARK: - Target

    func targetFile(_ fileURL: URL) {
        let folderURL = fileURL.deletingLastPathComponent()
        browserState.selectedFolderURL = folderURL
        browserState.selectedFileURL = fileURL
        folderListState.expandFoldersUntilSelectedFolder()
    }

    func targetFolder(_ folderURL: URL) {
        browserState.selectedFolderURL = folderURL
        folderListState.expandFoldersUntilSelectedFolder()
    }

    // MARK: - New File

//    func showNewFileSheet(on folderURL: URL?) {
//        guard let folderURL else { return }
//    }

    func newFileSubmitted(with newName: String) {
    }

    func makeNewFile(in folderURL: URL?) {
        guard let folderURL else { return }

        guard let defaultFileName = appState?.newFileName else { return }
        let defaultFileURL = URL(fileURLWithPath: defaultFileName)
        let namePart = defaultFileURL.deletingPathExtension().lastPathComponent
        let extensionPart = defaultFileURL.pathExtension

        var newFileURL = folderURL.appending(path: defaultFileName, directoryHint: .notDirectory)
        var counter = 1

        let fileManager = FileManager.default

        while fileManager.fileExists(atPath: newFileURL.path(percentEncoded: false)), counter < 100 {
            let newName = "\(namePart) \(counter).\(extensionPart)"
            newFileURL = folderURL.appending(path: newName, directoryHint: .notDirectory)
            counter += 1
        }

        do {
            consoleLog("new file: \(newFileURL.path(percentEncoded: false))")
            try "".write(to: newFileURL, atomically: true, encoding: .utf8)
            targetFile(newFileURL)
            fileListState.loadFileList()
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    func makeNewFile() {
        makeNewFile(in: browserState.selectedFolderURL)
    }

    // MARK: - New File with Template Sheet

    func showNewFileWithTemplate(on folderURL: URL?) {
        guard let folderURL else { return }
        guard let rootURL = browserState.rootURL else { return }
        guard let relativePath = folderURL.relativePath(from: rootURL) else { return }
        newFileWithTemplateContext = NewFileWithTemplateContext(folderRelativePath: relativePath)
        isNewFileWithTemplatePresented = true
    }

    func showNewFileWithTemplate() {
        showNewFileWithTemplate(on: browserState.selectedFolderURL)
    }

    func newFileWithTemplateSubmitted(with newFilePath: String) {
        guard let rootURL = browserState.rootURL else { return }
        let fileManager = FileManager.default
        let newFileURL = rootURL.appending(path: newFilePath).standardizedFileURL
        var newFolderURL: URL? = nil
        do {
            if !fileManager.fileExists(atPath: newFileURL.path(percentEncoded: false)) {
                let folderURL = newFileURL.deletingLastPathComponent()
                if !fileManager.fileExists(atPath: folderURL.path(percentEncoded: false)) {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    newFolderURL = folderURL
                }
                consoleLog("new file: \(newFileURL.path(percentEncoded: false))")
                try "".write(to: newFileURL, atomically: true, encoding: .utf8)
            }
            if newFolderURL != nil {
                folderListState.reloadFolderTree()
            }
            targetFile(newFileURL)
            fileListState.loadFileList()
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    // MARK: - New Folder

    func makeNewFolder(in folderURL: URL?) {
        guard let folderURL else { return }
        let fileManager = FileManager.default
        var newFolderURL = folderURL.appending(path: "NewFolder", directoryHint: .isDirectory)
        var counter = 1

        while fileManager.fileExists(atPath: newFolderURL.path(percentEncoded: false)), counter < 100 {
            let newName = "NewFolder \(counter)"
            newFolderURL = folderURL.appending(path: newName, directoryHint: .isDirectory)
            counter += 1
        }

        do {
            consoleLog("new folder: \(newFolderURL.path(percentEncoded: false))")
            try fileManager.createDirectory(at: newFolderURL, withIntermediateDirectories: true, attributes: nil)
            folderListState.reloadFolderTree()
            targetFolder(newFolderURL)
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    func makeNewFolder() {
        let folderURL = browserState.selectedFolderURL
        makeNewFolder(in: folderURL)
    }

    // MARK: - Rename File Sheet

    func showRenameFile(for selection: Set<FileState.ID>) {
        guard selection.count == 1 else { return }
        guard let url = selection.first else { return }
        renameFileContext = RenameFileContext(oldURL: url)
        isRenameFilePresented = true
    }

    func showRenameFile() {
        showRenameFile(for: browserState.selectedFileURLs)
    }

    func renameFileSubmitted(with newName: String) {
        guard let context = renameFileContext else { return }
        let oldURL = context.oldURL
        let newURL = oldURL.deletingLastPathComponent()
            .appending(path: newName, directoryHint: .notDirectory)
            .standardized
        do {
            consoleLog("rename file: \(oldURL.path(percentEncoded: false)) to \(newName)")
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            if self.browserState.selectedFileURL == oldURL {
                self.fileListState.loadFileList()
                self.browserState.selectedFileURL = newURL
            } else {
                self.fileListState.loadFileList()
            }
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("rename: \(message)")
        }
    }

    // MARK: - Rename File Sheet

    func showRenameFolder(for url: URL?) {
        guard let url else { return }
        renameFolderContext = RenameFolderContext(oldURL: url)
        isRenameFolderPresented = true
    }

    func showRenameFolder() {
        showRenameFolder(for: browserState.selectedFolderURL)
    }

    func renameFolderSubmitted(with newName: String) {
        guard let context = renameFolderContext else { return }
        let oldURL = context.oldURL
        let newURL = oldURL.deletingLastPathComponent()
            .appending(path: newName, directoryHint: .isDirectory)
            .standardized
        do {
            consoleLog("rename folder: \(oldURL.path(percentEncoded: false)) to \(newName)")
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            self.folderListState.reloadFolderTree()
            if self.browserState.selectedFolderURL == oldURL {
                self.browserState.selectedFolderURL = newURL
            }
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("rename: \(message)")
        }
    }
}
