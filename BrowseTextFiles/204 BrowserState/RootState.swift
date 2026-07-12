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
    // MARK: - ID

    let id = UUID()
    weak var window: NSWindow?

    // MARK: - Status

    enum BrowserStatus {
        case showOpenPanel
        case loading
        case ready
    }

    var status: BrowserStatus = .loading

    // MARK: - New File Sheet

    struct NewFileSheetParam {
        let folderRelativePath: String
    }

    @ObservationIgnored var newFileSheetParam: NewFileSheetParam?

    var isNewFileSheetPresented = false

    // MARK: - Rename Sheet

    struct RenameSheetParam {
        let oldURL: URL
        let onComplete: (URL, URL) -> Void
    }

    @ObservationIgnored var renameSheetParam: RenameSheetParam?

    var isRenameSheetPresented = false

    // MARK: - States

    @ObservationIgnored var browserState: BrowserState
    @ObservationIgnored var folderTreeState: FolderTreeState
    @ObservationIgnored var fileListState: FileListState
    @ObservationIgnored var searchState: SearchState
    @ObservationIgnored var historyState: HistoryState
    @ObservationIgnored var editorState: EditorState

    init() {
        browserState = BrowserState()
        folderTreeState = FolderTreeState(browserState: browserState)
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

    func configure(with rootURL: URL) {
        consoleLog("configure browser: \(rootURL.path(percentEncoded: false))")
        browserState.configure(with: rootURL)
        folderTreeState.reloadFolderTree()
        browserState.selectedFolderURL = rootURL
    }

    func reload() {
        consoleLog("reload:")
        folderTreeState.reloadFolderTree()
        fileListState.loadFileList(at: browserState.selectedFolderURL)
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
            browserState.targetFile(newFileURL)
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
                folderTreeState.reloadFolderTree()
            }
            browserState.targetFile(newFileURL)
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    // MARK: - Rename Sheet

    func showRenameFileSheet(for selection: Set<FileState.ID>) {
        guard selection.count == 1 else { return }
        guard let url = selection.first else { return }
        renameSheetParam = RenameSheetParam(oldURL: url) { oldURL, newURL in
            let browserState = self.browserState
            let fileListState = self.fileListState
            if browserState.selectedFileURL == oldURL {
                fileListState.loadFileList(at: browserState.selectedFolderURL)
                browserState.selectedFileURL = newURL
            } else {
                fileListState.loadFileList(at: browserState.selectedFolderURL)
            }
        }
        isRenameSheetPresented = true
    }

    func showRenameFileSheet() {
        showRenameFileSheet(for: browserState.selectedFileURLs)
    }

    func showRenameFolderSheet(for selection: Set<FileState.ID>) {
        guard selection.count == 1 else { return }
        guard let url = selection.first else { return }
        renameSheetParam = RenameSheetParam(oldURL: url) { oldURL, newURL in
            let browserState = self.browserState
            let folderTreeState = self.folderTreeState
            if browserState.selectedFolderURL == oldURL {
                folderTreeState.reloadFolderTree()
                browserState.selectedFolderURL = newURL
            } else {
                folderTreeState.reloadFolderTree()
            }
        }
        isRenameSheetPresented = true
    }

    func showRenameFolderSheet() {
        showRenameFolderSheet(for: browserState.selectedFolderURLs)
    }

    func renameSheetSubmitted(with newName: String) {
        guard let renameSheetParam else { return }
        let renamingURL = renameSheetParam.oldURL
        let newURL = renamingURL.deletingLastPathComponent().appending(path: newName).standardizedFileURL
        do {
            consoleLog("rename: \(renamingURL.path(percentEncoded: false)) to \(newName)")
            try FileManager.default.moveItem(at: renamingURL, to: newURL)
            renameSheetParam.onComplete(renamingURL, newURL)
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("rename: \(message)")
        }
    }
}
