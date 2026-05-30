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

    var rootFolder: FolderForView?

    var expandedFolders: Set<URL> = []

    var selectedFolderID: FolderForView.ID?
    var selectedFolder: FolderForView?

    var fileList: [FileForView]?

    var selectedFileID: FileForView.ID?
    var selectedFile: FileForView?

    var fileBuffer: TextBuffer?

    var workingFolderID: FolderForView.ID?
    var workingFolder: FolderForView?

    var workingFileID: FileForView.ID?
    var workingFile: FileForView?

    var workingRelativePath: String?

    var isShowNewFolderSheet = false
    var isShowNewFileSheet = false
    var isShowRenameFolderSheet = false
    var isShowRenameFileSheet = false

    var searchText = ""
    var isSearching = false
    var searchResults: [SearchResult]?

    var history: [URLForView] = []

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

        let fileURL = fileBuffer?.url

        loadFolderTree()
        if hasAlertMessage { return }

        if let fileURL {
            locateFile(with: fileURL)
        }
    }

    func locateFile(with fileURL: URL) {
        LogStore.shared.log("locate file: \(fileURL.path(percentEncoded: false))")

        let folderURL = fileURL.deletingLastPathComponent()

        selecteFolder(with: folderURL)
        loadFileList(preserveSelection: false)
        if hasAlertMessage { return }

        guard fileList != nil else { return }

        expandFolders(for: folderURL)
        selecteFile(withURL: fileURL)
        loadFileBuffer()
    }

}
