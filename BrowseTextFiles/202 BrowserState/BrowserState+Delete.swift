//
//  BrowserState+Delete.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/30/26.
//

import Foundation

extension BrowserState {

    func trashFolder(at url: URL) {
        do {
            let fileManager = FileManager.default

            let deletingSelectedFolder = selectedFolder?.url.isChildOrEqual(to: url) ?? false
            let deletingSelectedFile = editorState.editingFileURL?.isChild(of: url) ?? false

            if deletingSelectedFile {
                guard editorState.closeFile() else { return }
            }
            consoleLog("deleting folder: \(url.path(percentEncoded: false))")
            try fileManager.trashItem(at: url, resultingItemURL: nil)
            if deletingSelectedFolder {
                loadFolderTree(preserveSelection: false)
                selectFolder(with: url.deletingLastPathComponent())
                fileListState.loadFileList(at: selectedFolder?.url)
            } else {
                loadFolderTree()
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("delete folder: \(message)")
        }
    }


}
