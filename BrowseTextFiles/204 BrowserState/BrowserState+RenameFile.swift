//
//  BrowserState+RenameFile.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func showRenameSheet(for url: URL, isFolder: Bool) {
        renamingURL = url
        isRenamingFolder = isFolder
        isShowRenameSheet = true
    }

    func renameRenamingURL(with newName: String) {
        guard let renamingURL else { return }
        let newURL = renamingURL.deletingLastPathComponent().appending(path: newName).standardizedFileURL
        let fileManager = FileManager.default
        let renamingSelectedFolder = selectedFolder?.url.isChildOrEqual(to: renamingURL) ?? false
        let renamingSelectedFile = fileListState.selectedFile?.url.isChildOrEqual(to: renamingURL) ?? false
        do {
            if renamingSelectedFile {
                guard editorState.closeFile() else { return }
            }
            LogStore.shared.log("renaming: \(renamingURL.path) to \(newName)")
            try fileManager.moveItem(at: renamingURL, to: newURL)
            if isRenamingFolder {
                if renamingSelectedFolder {
                    loadFolderTree(preserveSelection: false)
                    selectFolder(with: newURL)
                    expandFolders(for: newURL)
                    fileListState.loadFileList(at: selectedFolder?.url, preserveSelection: false)
                } else {
                    loadFolderTree()
                }
            } else {
                if renamingSelectedFile {
                    fileListState.loadFileList(at: selectedFolder?.url, preserveSelection: false)
                    fileListState.selectFile(withURL: newURL)
                    editorState.loadFile(at: newURL)
                } else {
                    fileListState.loadFileList(at: selectedFolder?.url)
                }
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            LogStore.shared.log("rename file: \(message)")
        }
    }
    
}
