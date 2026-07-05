//
//  BrowserState+NewFolder.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func makeNewFolder(in folderURL: URL? = nil) {
        let folderURL = folderURL ?? selectedFolder?.url
        guard let folderURL else { return }
        let fileManager = FileManager.default
        var newFolderURL = folderURL.appending(path: "NewFolder", directoryHint: .isDirectory)
        var counter = 1

        while fileManager.fileExists(atPath: newFolderURL.path), counter < 100 {
            let newName = "NewFolder \(counter)"
            newFolderURL = folderURL.appending(path: newName, directoryHint: .isDirectory)
            counter += 1
        }

        do {
            guard editorState.closeFile() else { return }

            consoleLog("new folder: \(newFolderURL.path)")
            try fileManager.createDirectory(at: newFolderURL, withIntermediateDirectories: true, attributes: nil)
            loadFolderTree(preserveSelection: false)

            selectFolder(with: newFolderURL)
            fileListState.loadFileList(at: selectedFolder?.url)
            expandFolders(for: newFolderURL)
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("new file: \(message)")
        }
    }

}
