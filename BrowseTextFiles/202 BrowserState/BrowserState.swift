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

    // BrowserStatus

    enum BrowserStatus {
        case showOpenPanel
        case loading
        case ready
    }

    var status: BrowserStatus = .loading

    // New File Sheet

    struct NewFileSheetParam {
        let folderRelativePath: String
    }

    @ObservationIgnored var newFileSheetParam: NewFileSheetParam?

    var isNewFileSheetPresented = false

    // States

    @ObservationIgnored var rootState: RootState
    @ObservationIgnored var targetState: TargetState
    @ObservationIgnored var alertState: AlertState
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
            targetState.targetFile(newFileURL)
        } catch {
            let message = error.localizedDescription
            alertState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    func makeNewFile() {
        makeNewFile(in: targetState.selectedFolderURL)
    }

    // MARK: - New File Sheet

    func showNewFileSheet(on folderURL: URL?) {
        guard let folderURL else { return }
        guard let rootURL = rootState.rootURL else { return }
        guard let relativePath = folderURL.relativePath(from: rootURL) else { return }
        newFileSheetParam = NewFileSheetParam(folderRelativePath: relativePath)
        isNewFileSheetPresented = true
    }

    func showNewFileSheet() {
        showNewFileSheet(on: targetState.selectedFolderURL)
    }

    func makeNewFile(with newFilePath: String) {
        guard let rootURL = rootState.rootURL else { return }
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
            targetState.targetFile(newFileURL)
        } catch {
            let message = error.localizedDescription
            alertState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    // MARK: - Rename Folder

//    func showRenameFolderSheet(selection: Set<FileState.ID>) {
//        guard selection.count == 1 else { return }
//        guard let url = selection.first else { return }
//        renameState.showRenameSheet(for: url) { oldURL, newURL in
//            if targetState.selectedFolderURL == oldURL {
//                folderTreeState.reloadFolderTree()
//                targetState.selectedFolderURL = newURL
//            } else {
//                folderTreeState.reloadFolderTree()
//            }
//        }
//    }

}
