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
    weak var window: NSWindow?

    enum BrowserStatus {
        case showOpenPanel
        case loading
        case ready
    }

    var status: BrowserStatus = .loading

    @ObservationIgnored var rootState: RootState
    @ObservationIgnored var targetState: TargetState
    @ObservationIgnored var alertState: AlertState
    @ObservationIgnored var newFileState: NewFileState
    @ObservationIgnored var renameState: RenameState
    @ObservationIgnored var folderTreeState: FolderTreeState
    @ObservationIgnored var fileListState: FileListState
    @ObservationIgnored var searchState: SearchState
    @ObservationIgnored var historyState: HistoryState
    @ObservationIgnored var editorState: EditorState

    init() {
        rootState = RootState()
        targetState = TargetState()
        alertState = AlertState()
        newFileState = NewFileState(rootState: rootState, alertState: alertState)
        renameState = RenameState(alertState: alertState)
        folderTreeState = FolderTreeState(rootState: rootState, targetState: targetState, alertState: alertState)
        fileListState = FileListState(targetState: targetState, alertState: alertState)
        searchState = SearchState(alertState: alertState)
        historyState = HistoryState()
        editorState = EditorState(alertState: alertState)

        printLog("init browser state: \(id)")
    }

    func releaseResource() {
        consoleLog("release browser resource:")
        rootState.releaseResource()
    }

    func configure(with rootURL: URL) {
        consoleLog("configure browser: \(rootURL.path(percentEncoded: false))")
        rootState.configure(with: rootURL)
        folderTreeState.reloadFolderTree()
        targetState.selectedFolderURL = rootURL
    }

    func reload() {
        consoleLog("reload:")
        folderTreeState.reloadFolderTree()
        fileListState.loadFileList(at: targetState.selectedFolderURL)
    }

    // MARK: - New File

    func makeNewFile(in folderURL: URL?) {
        guard let folderURL else { return }
        newFileState.makeNewFile(in: folderURL) { newFileURL in
            self.targetState.targetFile(newFileURL)
        }
    }

    func makeNewFile() {
        makeNewFile(in: targetState.selectedFolderURL)
    }

    func showNewFileSheet(for folderURL: URL?) {
        guard let folderURL else { return }
        newFileState.showNewFileSheet(on: folderURL) { newFolderURL, newFileURL in
            if newFolderURL != nil {
                self.folderTreeState.reloadFolderTree()
            }
            self.targetState.targetFile(newFileURL)
        }
    }

    func showNewFileSheet() {
        showNewFileSheet(for: targetState.selectedFolderURL)
    }

}
