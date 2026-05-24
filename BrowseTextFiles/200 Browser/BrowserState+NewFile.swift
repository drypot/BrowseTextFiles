//
//  BrowserState+NewFile.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func showNewFileView() {
        guard autoSaveFileBuffer() else { return }

        if selectedFolderID == nil {
            showAlert("Select folder first.")
        } else {
            isShowNewFileView = true
        }
    }

    func makeNewFile(path: String) {
        do {
            guard let rootURL else { return }
            let fileManager = FileManager.default
            let newFileURL = rootURL.appending(component: path)
            try withSecurityScope(rootURL) {
                if fileManager.fileExists(atPath: newFileURL.path) {
                    // do nothing
                } else {
                    let folderURL = newFileURL.deletingLastPathComponent()
                    if fileManager.fileExists(atPath: folderURL.path) {
                        // do nothing
                    } else {
                        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                        updateFolderTree()
                    }
                    try "".write(to: newFileURL, atomically: true, encoding: .utf8)
                    LogStore.shared.log("new file: \(path)")
                }
                updateAll(fromFileURL: newFileURL)
            }
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            LogStore.shared.log("new file: \(message)")
        }
    }
    
}
