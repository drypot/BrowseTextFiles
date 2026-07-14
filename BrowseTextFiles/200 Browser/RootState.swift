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

    struct NewFileSheetParam {
        let folderRelativePath: String
    }

    @ObservationIgnored var newFileSheetParam: NewFileSheetParam?

    var isNewFileSheetPresented = false

    // MARK: - Rename Sheet

    struct RenameSheetParam {
        let oldURL: URL
        let isDirectory: Bool
        let onComplete: (URL, URL) -> Void
    }

    @ObservationIgnored var renameSheetParam: RenameSheetParam?

    var isRenameSheetPresented = false

    // MARK: - States

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

    func makeNewFile(in folderURL: URL?) {
        guard let folderURL else { return }
        let fileManager = FileManager.default
        var newFileURL = folderURL.appending(path: "Untitled.md", directoryHint: .notDirectory)
        var counter = 1

        while fileManager.fileExists(atPath: newFileURL.path(percentEncoded: false)), counter < 100 {
            let newName = "Untitled \(counter).md"
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

    // MARK: - New File Sheet

    func showNewFileSheet(on folderURL: URL?) {
        guard let folderURL else { return }
        guard let rootURL = browserState.rootURL else { return }
        guard let relativePath = folderURL.relativePath(from: rootURL) else { return }
        newFileSheetParam = NewFileSheetParam(folderRelativePath: relativePath)
        isNewFileSheetPresented = true
    }

    func showNewFileSheet() {
        showNewFileSheet(on: browserState.selectedFolderURL)
    }

    func newFileSheetSubmitted(with newFilePath: String) {
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

    // MARK: - Rename Sheet

    func showRenameFileSheet(for selection: Set<FileState.ID>) {
        guard selection.count == 1 else { return }
        guard let url = selection.first else { return }
        renameSheetParam = RenameSheetParam(oldURL: url, isDirectory: false) { oldURL, newURL in
            if self.browserState.selectedFileURL == oldURL {
                self.fileListState.loadFileList()
                self.browserState.selectedFileURL = newURL
            } else {
                self.fileListState.loadFileList()
            }
        }
        isRenameSheetPresented = true
    }

    func showRenameFileSheet() {
        showRenameFileSheet(for: browserState.selectedFileURLs)
    }

    func showRenameFolderSheet(for url: URL?) {
        guard let url else { return }
        renameSheetParam = RenameSheetParam(oldURL: url, isDirectory: true) { oldURL, newURL in
            self.folderListState.reloadFolderTree()
            if self.browserState.selectedFolderURL == oldURL {
                self.browserState.selectedFolderURL = newURL
            }
        }
        isRenameSheetPresented = true
    }

    func showRenameFolderSheet() {
        showRenameFolderSheet(for: browserState.selectedFolderURL)
    }

    func renameSheetSubmitted(with newName: String) {
        guard let param = renameSheetParam else { return }
        let oldURL = param.oldURL
        let newURL = oldURL.deletingLastPathComponent()
            .appending(path: newName, directoryHint: param.isDirectory ? .isDirectory : .notDirectory)
            .standardized
        do {
            consoleLog("rename: \(oldURL.path(percentEncoded: false)) to \(newName)")
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            param.onComplete(oldURL, newURL)
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("rename: \(message)")
        }
    }
}
