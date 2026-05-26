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
    var shouldStopAccessingSecurityScopedResource = false

    var rootFolder: FolderForView?

    var expandedFolders: Set<URL> = []

    var selectedFolderID: FolderForView.ID?
    var selectedFolder: FolderForView?

    var renameFolderID: FolderForView.ID?
    var isShowRenameFolderView = false

    var fileList: [FileForView]?

    var selectedFileID: FileForView.ID?
    var selectedFile: FileForView?

    var renameFileID: FileForView.ID?
    var isShowRenameFileView = false

    var fileBuffer: TextBuffer?

    var isShowNewFileView = false

    var searchText = ""
    var isSearching = false
    var searchResults: [SearchResult]?

    var history: [URLForView] = []

    var alertMessage: String = ""
    var hasAlertMessage = false

    // MARK: - Root

    func releaseResource() {
        if let rootURL, shouldStopAccessingSecurityScopedResource {
            rootURL.stopAccessingSecurityScopedResource()
            shouldStopAccessingSecurityScopedResource = false
        }
    }

    func initRoot(with url: URL) {
        rootURL = url
        rootName = url.lastPathComponent
        rootPathComponents = url.pathComponents
        shouldStopAccessingSecurityScopedResource = url.startAccessingSecurityScopedResource()
    }

    var isRootReady: Bool {
        rootFolder != nil
    }

    // MARK: - Alert

    func showAlert(_ message: String) {
        alertMessage = message
        hasAlertMessage = true
    }

    // MARK: - Update All

    func updateAll(fileURL: URL?) {
        updateFolderTree()
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

        LogStore.shared.log("reload all:")
    }

}
