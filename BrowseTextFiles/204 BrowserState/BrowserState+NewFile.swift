//
//  BrowserState+NewFile.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func showNewFileSheet(for folder: FolderState? = nil) {
        guard let folder = folder ?? selectedFolder else { return }
        guard autoSaveFileBuffer() else { return }
        setupWorkingFolder(with: folder)
        isShowNewFileSheet = true
    }

    func makeNewFile(with newFilePath: String) {
        do {
            guard let rootURL else { return }
            let fileManager = FileManager.default
            let newFileURL = rootURL.appending(path: newFilePath).standardizedFileURL
            if !fileManager.fileExists(atPath: newFileURL.path) {
                let folderURL = newFileURL.deletingLastPathComponent()
                if !fileManager.fileExists(atPath: folderURL.path) {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    loadFolderTree()
                }
                LogStore.shared.log("new file: \(newFileURL.path)")
                try "".write(to: newFileURL, atomically: true, encoding: .utf8)
            }
            locateFile(with: newFileURL)
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            LogStore.shared.log("new file: \(message)")
        }
    }

    func makeNewFile(in folderURL: URL? = nil) {
        let folderURL = folderURL ?? selectedFolder?.url
        guard let folderURL else { return }
        let fileManager = FileManager.default
        var newFileURL = folderURL.appending(path: "Untitled.txt", directoryHint: .notDirectory)
        var counter = 1

        while fileManager.fileExists(atPath: newFileURL.path), counter < 100 {
            let newName = "Untitled \(counter).txt"
            newFileURL = folderURL.appending(path: newName, directoryHint: .notDirectory)
            counter += 1
        }

        do {
            LogStore.shared.log("new file: \(newFileURL.path)")
            try "".write(to: newFileURL, atomically: true, encoding: .utf8)
            locateFile(with: newFileURL)
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            LogStore.shared.log("new file: \(message)")
        }
    }

}
