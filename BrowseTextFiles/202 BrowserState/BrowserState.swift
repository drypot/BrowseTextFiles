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

    var rootURL: URL?
    var rootName: String?
    var rootPathComponents: [String]?
    var shouldReleaseSecurityScopedResource = false

    //var rootWatcher: FolderWatcher?

    var rootFolder: FolderState?
    var rootFolderRefreshID = UUID()

    var expandedFolderIDs: Set<FolderState.ID> = []
    var selectedFolderIDs: Set<FolderState.ID> = []

    var selectedFolderID: FolderState.ID?
    var selectedFolder: FolderState?

    var workingFolderID: FolderState.ID?
    var workingFolder: FolderState?

    var workingFileID: FileState.ID?
    var workingFile: FileState?

    var workingRelativePath: String?

    var renamingURL: URL?
    var isRenamingFolder: Bool = true

    var isShowNewFileSheet = false
    var isShowRenameSheet = false

    @ObservationIgnored var alertState: AlertState
    @ObservationIgnored var searchState: SearchState
    @ObservationIgnored var historyState: HistoryState
    @ObservationIgnored var editorState: EditorState
    @ObservationIgnored var fileListState: FileListState

    // MARK: - Init / Release

    init() {
        print("--- BrowserState \(id)")
        self.alertState = AlertState()
        self.searchState = SearchState()
        self.historyState = HistoryState()
        self.editorState = EditorState(alertState: alertState)
        self.fileListState = FileListState(alertState: alertState)
    }

    func initState(with rootURL: URL, fileURL: URL?) {
        LogStore.shared.log("init root: \(rootURL.path(percentEncoded: false))")

        self.rootURL = rootURL
        rootName = rootURL.lastPathComponent
        rootPathComponents = rootURL.pathComponents
        shouldReleaseSecurityScopedResource = rootURL.startAccessingSecurityScopedResource()

        //rootWatcher = FolderWatcher()
        //rootWatcher?.startWatching(url) {
        //    print("root watcher: changed")
        //}

        loadFolderTree(preserveSelection: false)
        if alertState.hasMessage { return }

        if let fileURL {
            locateFile(with: fileURL)
        } else {
            selectFolder(rootFolder)
            fileListState.loadFileList(at: selectedFolder?.url, preserveSelection: false)
        }
    }

    func releaseResource() {
        print("release browser resource:")

        guard let rootURL else { return }
        if shouldReleaseSecurityScopedResource {
            rootURL.stopAccessingSecurityScopedResource()
            shouldReleaseSecurityScopedResource = false
        }
        //rootWatcher?.stopWatching()
    }

    // MARK: - Root

    var isRootReady: Bool {
        rootFolder != nil
    }

    // MARK: - Update All

    func reloadAll() {
        LogStore.shared.log("reload all:")

        guard editorState.autoSaveFile() else { return }

        let fileURL = editorState.editingFileURL

        loadFolderTree()
        if alertState.hasMessage { return }

        if let fileURL {
            locateFile(with: fileURL)
        }
    }

    func locateFile(with fileURL: URL) {
        LogStore.shared.log("locate file: \(fileURL.path(percentEncoded: false))")

        guard editorState.closeFile() else { return }

        let folderURL = fileURL.deletingLastPathComponent()

        selectFolder(with: folderURL)
        fileListState.loadFileList(at: selectedFolder?.url, preserveSelection: false)
        if alertState.hasMessage { return }

        guard fileListState.fileList != nil else { return }

        expandFolders(for: folderURL)
        fileListState.selectFile(with: fileURL)
        //editorState.loadFile(at: fileURL)
    }

}
