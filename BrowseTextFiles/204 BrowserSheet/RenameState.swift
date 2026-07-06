//
//  RenameState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/6/26.
//

import SwiftUI

@Observable
final class RenameState {
    typealias CompletionHandler = (URL, URL) -> Void

    private(set) var renamingURL: URL?
    private(set) var isFolder: Bool = true
    private var onComplete: CompletionHandler?

    var isRenameSheetPresented = false

    @ObservationIgnored private(set) var alertState: AlertState

    init(alertState: AlertState) {
        self.alertState = alertState
    }

    func showRenameSheet(for url: URL, onComplete: @escaping CompletionHandler) {
        self.renamingURL = url
        self.onComplete = onComplete
        self.isRenameSheetPresented = true
    }

    func rename(with newName: String) {
        guard let renamingURL else { return }
        let newURL = renamingURL.deletingLastPathComponent().appending(path: newName).standardizedFileURL
//        let renamingSelectedFolder = selectedFolder?.url.isChildOrEqual(to: renamingURL) ?? false
//        let renamingSelectedFile = fileListState.selectedFile?.url.isChildOrEqual(to: renamingURL) ?? false
        do {
//            if renamingSelectedFile {
//                guard editorState.closeFile() else { return }
//            }
            consoleLog("rename: \(renamingURL.path(percentEncoded: false)) to \(newName)")
            try FileManager.default.moveItem(at: renamingURL, to: newURL)

//            if isFolder {
//                if renamingSelectedFolder {
//                    loadFolderTree(preserveSelection: false)
//                    selectFolder(with: newURL)
//                    expandFolders(for: newURL)
//                    fileListState.loadFileList(at: selectedFolder?.url, preserveSelection: false)
//                } else {
//                    loadFolderTree()
//                }
//            }

            onComplete?(renamingURL, newURL)
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("rename: \(message)")
        }
    }
}
