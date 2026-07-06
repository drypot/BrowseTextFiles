//
//  BrowserState.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

@Observable
final class BrowserState: Identifiable {
    let id = UUID()

    var rootFolder: FolderState?
    var rootFolderRefreshID = UUID()

    var expandedFolderIDs: Set<FolderState.ID> = []
    var selectedFolderIDs: Set<FolderState.ID> = []

    var selectedFolderID: FolderState.ID?
    var selectedFolder: FolderState?

    @ObservationIgnored var rootState: RootState
    @ObservationIgnored var alertState: AlertState
    @ObservationIgnored var newFileState: NewFileState
    @ObservationIgnored var renameState: RenameState
    @ObservationIgnored var fileListState: FileListState
    @ObservationIgnored var searchState: SearchState
    @ObservationIgnored var historyState: HistoryState
    @ObservationIgnored var editorState: EditorState

    // MARK: - Init / Release

    init() {
        rootState = RootState()
        alertState = AlertState()
        newFileState = NewFileState(rootState: rootState, alertState: alertState)
        renameState = RenameState(alertState: alertState)
        fileListState = FileListState(alertState: alertState)
        searchState = SearchState()
        historyState = HistoryState()
        editorState = EditorState(alertState: alertState)

        // 여기서 log 쓰면 무한 루프.
        printLog("init browser state: \(id)")
    }

    func initState(with rootURL: URL, fileURL: URL?) {
        consoleLog("init root: \(rootURL.path(percentEncoded: false))")

        rootState.configure(with: rootURL)

        loadFolderTree(preserveSelection: false)
        if alertState.hasMessage { return }

        if let fileURL {
            loadFile(at: fileURL)
        } else {
            selectFolder(rootFolder)
            fileListState.loadFileList(at: selectedFolder?.url)
        }
    }

    func releaseResource() {
        consoleLog("release resource:")
        rootState.releaseResource()
    }

    // MARK: - Update All

    func reloadAll() {
        consoleLog("reload all:")

        guard editorState.autoSaveFile() else { return }

        let fileURL = editorState.editingFileURL

        loadFolderTree()
        if alertState.hasMessage { return }

        if let fileURL {
            loadFile(at: fileURL)
        }
    }

    func loadFile(at fileURL: URL) {
        let folderURL = fileURL.deletingLastPathComponent()

        selectFolder(with: folderURL)
        expandFolders(for: folderURL)
        if alertState.hasMessage { return }

        fileListState.loadFileList(at: folderURL)
        fileListState.selectFile(with: fileURL)
        if alertState.hasMessage { return }
    }

    // MARK: - New File

    func makeNewFile(in folderURL: URL) {
        newFileState.makeNewFile(in: folderURL) { newFileURL in
            self.loadFile(at: newFileURL)
        }
    }

    func makeNewFile() {
        guard let folderURL = fileListState.folderURL else { return }
        makeNewFile(in: folderURL)
    }

    func showNewFileSheet(for folderURL: URL) {
        newFileState.showNewFileSheet(for: folderURL) { newFolderURL, newFileURL in
            if newFolderURL != nil {
                self.loadFolderTree()
            }
            self.loadFile(at: newFileURL)
        }
    }

    func showNewFileSheet() {
        guard let folderURL = fileListState.folderURL else { return }
        showNewFileSheet(for: folderURL)
    }
}
