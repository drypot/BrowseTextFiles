//
//  BrowserState+RenameFile.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {

    func setupWorkingFolder(with folder: FolderState) {
        workingFolderID = nil
        workingFolder = nil
        workingRelativePath = nil
        guard let rootURL = rootURL else { return }
        guard let relativePath = folder.url.relativePath(from: rootURL) else { return }
        workingFolderID = folder.id
        workingFolder = folder
        workingRelativePath = relativePath
    }

    func setupWorkingFolder(with id: FolderState.ID) {
        guard let folder = findFolder(with: id) else { return }
        setupWorkingFolder(with: folder)
    }

    func setupWorkingFile(with file: FileState) {
        workingFileID = nil
        workingFile = nil
        workingRelativePath = nil
        guard let rootURL = rootURL else { return }
        guard let relativePath = file.url.relativePath(from: rootURL) else { return }
        workingFileID = file.id
        workingFile = file
        workingRelativePath = relativePath
    }

    func setupWorkingFile(with id: FileState.ID) {
        guard let file = findFile(with: id) else { return }
        setupWorkingFile(with: file)
    }
    
}
