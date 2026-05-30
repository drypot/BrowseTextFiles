//
//  BrowserState+NewFile.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func showNewFileSheet(for folder: FolderForView? = nil) {
        guard let folder = folder ?? selectedFolder else { return }
        guard autoSaveFileBuffer() else { return }
        setupWorkingFolder(with: folder)
        isShowNewFileSheet = true
    }

    func makeNewFile(with newFilePath: String) {
        LogStore.shared.log("new file: \(newFilePath)")
        do {
            guard let rootURL else { return }
            let fileManager = FileManager.default
            let newFileURL = rootURL.appending(component: newFilePath)
            if fileManager.fileExists(atPath: newFileURL.path) {
                // do nothing
            } else {
                let folderURL = newFileURL.deletingLastPathComponent()
                if fileManager.fileExists(atPath: folderURL.path) {
                    // do nothing
                } else {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    loadFolderTree()
                }
                try "".write(to: newFileURL, atomically: true, encoding: .utf8)
            }
            locateFile(with: newFileURL)
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            LogStore.shared.log("new file: \(message)")
        }
    }
    
}
