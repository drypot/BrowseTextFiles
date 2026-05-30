//
//  BrowserState+RenameFile.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func showRenameFolderSheet(for folder: FolderForView) {
        setupWorkingFolder(with: folder)
        isShowRenameFolderSheet = true
    }

    func renameWorkingFolder(with newRelativePath: String) {
        guard let rootURL = rootURL else { return }
        guard let orgURL = workingFolder?.url else { return }
        let newURL = rootURL.appending(path: newRelativePath)
        do {
            let fileManager = FileManager.default

            let shouldUpdateSelectedFolder = selectedFolder?.url.isChildOrEqual(to: orgURL) ?? false
            let shouldUpdateFileBuffer = fileBuffer?.url.isChild(of: orgURL) ?? false

            if shouldUpdateFileBuffer {
                guard closeFileBuffer() else { return }
            }
            try fileManager.moveItem(at: orgURL, to: newURL)
            if shouldUpdateSelectedFolder {
                loadFolderTree(preserveSelection: false)
                selecteFolder(with: newURL)
                expandFolders(for: newURL)
                loadFileList(preserveSelection: false)
            } else {
                loadFolderTree()
            }
            LogStore.shared.log("rename from: \(orgURL.relativePath)")
            LogStore.shared.log("rename to: \(newURL.relativePath)")
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            LogStore.shared.log("rename folder: \(message)")
        }
    }
    
    func showRenameFileSheet(for file: FileForView) {
        setupWorkingFile(with: file)
        isShowRenameFileSheet = true
    }

    func renameWorkingFile(with newRelativePath: String) {
        guard let rootURL = rootURL else { return }
        guard let orgURL = workingFile?.url else { return }
        let newURL = rootURL.appending(path: newRelativePath)
        do {
            let fileManager = FileManager.default

            let renamingSelectedFile = selectedFile?.url == orgURL

            if renamingSelectedFile {
                guard closeFileBuffer() else { return }
            }
            try fileManager.moveItem(at: orgURL, to: newURL)
            if renamingSelectedFile {
                loadFileList(preserveSelection: false)
                selecteFile(withURL: newURL)
                loadFileBuffer()
            } else {
                loadFileList()
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
