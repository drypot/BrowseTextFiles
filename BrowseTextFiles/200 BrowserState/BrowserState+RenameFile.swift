//
//  BrowserState+RenameFile.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func showRenameFile(id: FileForView.ID) {
        renameFileID = id
        isShowRenameFileView = true
    }

    func renameFile(from orgURL: URL, to newURL: URL) {
        do {
            let fileManager = FileManager.default
            let selectedFileURL = selectedFile?.url
            let shouldUpdateFileBuffer = selectedFileURL == orgURL
            if shouldUpdateFileBuffer {
                resetFileBuffer()
            }
            try fileManager.moveItem(at: orgURL, to: newURL)
            updateFileListFromSelectedFolder()
            if shouldUpdateFileBuffer {
                selecteFile(withURL: newURL)
                updateFileBufferFromSelectedFile()
            } else if let selectedFileURL {
                selecteFile(withURL: selectedFileURL)
            }
            LogStore.shared.log("rename from: \(orgURL.relativePath)")
            LogStore.shared.log("rename to: \(newURL.relativePath)")
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            LogStore.shared.log("rename file: \(message)")
        }
    }
    
}
