//
//  BrowserState+RenameFolder.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func showRenameFolder(id: FolderForView.ID) {
        renameFolderID = id
        isShowRenameFolderView = true
    }

    func renameFolder(from orgURL: URL, to newURL: URL) {
        do {
            let fileManager = FileManager.default
            
            let selectedFolderURL = selectedFolder?.url
            let shouldUpdateSelectedFolder = if let selectedFolderURL {
                selectedFolderURL.isChildOrEqual(to: orgURL)
            } else {
                false
            }

            // selectedFile 이 nil 이지만,
            // fileBuffer 가 nil 이 아닌 경우가 있다;
            let fileBufferURL = fileBuffer?.url
            let shouldUpdateFileBuffer = if let fileBufferURL {
                fileBufferURL.isChild(of: orgURL)
            } else {
                false
            }

            if shouldUpdateFileBuffer {
                resetFileBuffer()
            }
            try fileManager.moveItem(at: orgURL, to: newURL)
            if shouldUpdateSelectedFolder {
                updateFolderTree(preserveSelection: false)
                selecteFolder(withURL: newURL)
                expandFolders(for: newURL)
                updateFileListFromSelectedFolder()
            } else {
                updateFolderTree()
            }
            LogStore.shared.log("rename from: \(orgURL.relativePath)")
            LogStore.shared.log("rename to: \(newURL.relativePath)")
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            LogStore.shared.log("rename folder: \(message)")
        }
    }

}
