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
            LogStore.shared.log("deleting folder: \(url.path(percentEncoded: false))")
            try fileManager.trashItem(at: url, resultingItemURL: nil)
            if deletingSelectedFolder {
                loadFolderTree(preserveSelection: false)
                selectFolder(with: url.deletingLastPathComponent())
                loadFileList(preserveSelection: false)
            } else {
                loadFolderTree()
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            LogStore.shared.log("delete folder: \(message)")
        }
    }

    func trashFile(at url: URL) {
        do {
            let fileManager = FileManager.default

            let deletingSelectedFile = selectedFile?.url == url

            if deletingSelectedFile {
                guard editorState.closeFile() else { return }
            }
            LogStore.shared.log("deleting file: \(url.path(percentEncoded: false))")
            try fileManager.trashItem(at: url, resultingItemURL: nil)
            if deletingSelectedFile {
                loadFileList(preserveSelection: false)
            } else {
                loadFileList()
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            LogStore.shared.log("delete file: \(message)")
        }
    }

}
