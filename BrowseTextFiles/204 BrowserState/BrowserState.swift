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

    var expandedFolders: Set<URL> = []

    var selectedFolderID: FolderState.ID?
    var selectedFolder: FolderState?

    var fileList: [FileState]?

    var selectedFileID: FileState.ID?
    var selectedFile: FileState?

    var textBuffer: TextBuffer?

    var workingFolderID: FolderState.ID?
    var workingFolder: FolderState?

    var workingFileID: FileState.ID?
    var workingFile: FileState?

    var workingRelativePath: String?

    var renamingURL: URL?
    var isRenamingFolder: Bool = true

    var isShowNewFileSheet = false
    var isShowRenameSheet = false

    var searchText = ""
    var isSearching = false
    var searchResults: [SearchResult]?
    var isShowSearchWindow = false

    var history: [URLForView] = []
    var isShowHistoryWindow = false

    var alertMessage: String = ""
    var hasAlertMessage = false

    // MARK: - Init / Release

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
        if hasAlertMessage { return }

        if let fileURL {
            locateFile(with: fileURL)
        } else {
            selectFolder(rootFolder)
            loadFileList(preserveSelection: false)
        }
    }

    func releaseResource() {
        print("release resource:")

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

    // MARK: - Alert

    func showAlert(_ message: String) {
        alertMessage = message
        hasAlertMessage = true
    }

    // MARK: - Update All

    func reloadAll() {
        LogStore.shared.log("reload all:")

        guard autoSaveFileBuffer() else { return }

        let fileURL = textBuffer?.url

        loadFolderTree()
        if hasAlertMessage { return }

        if let fileURL {
            locateFile(with: fileURL)
        }
    }

    func locateFile(with fileURL: URL) {
        LogStore.shared.log("locate file: \(fileURL.path(percentEncoded: false))")

        guard closeFileBuffer() else { return }

        let folderURL = fileURL.deletingLastPathComponent()

        selectFolder(with: folderURL)
        loadFileList(preserveSelection: false)
        if hasAlertMessage { return }

        guard fileList != nil else { return }

        expandFolders(for: folderURL)
        selectFile(withURL: fileURL)
        loadFileBuffer()
    }

}
