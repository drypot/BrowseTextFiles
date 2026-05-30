//
//  BrowserState+FileList.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {
    // MARK: - File List

    func resetFileList() {
        fileList = nil
        deselecteFile()
    }

    func updateFileList(from url: URL) {
        resetFileList()
        do {
            fileList = try FileListBuilder().collectShallowly(from: url) { contentType in
                // contentType.conforms(to: .text)
                return true
            }
            fileList?.sort {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            LogStore.shared.log("load list: \(url.lastPathComponent)")
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            LogStore.shared.log("load list: \(message)")
        }
    }

    func updateFileListFromSelectedFolder() {
        if let selectedFolder {
            updateFileList(from: selectedFolder.url)
        } else {
            resetFileList()
        }
    }

    // MARK: - Selected File

    func findFile(with id: FileForView.ID) -> FileForView? {
        guard let fileList else { return nil }
        return fileList.first { $0.id ==  id }
    }

    func deselecteFile() {
        selectedFileID = nil
        selectedFile = nil
    }

    func selecteFile(_ fileItem: FileForView?) {
        if let fileItem {
            selectedFileID = fileItem.id
            selectedFile = fileItem
        } else {
            deselecteFile()
        }
    }

    func selecteFile(withID id: FileForView.ID?) {
        if let fileList, let file = fileList.first(where: { $0.id ==  id }) {
            selectedFileID = file.id
            selectedFile = file
        } else {
            deselecteFile()
        }
    }

    func selecteFile(withURL url: URL) {
        if let fileList, let file = fileList.first(where: { $0.url ==  url }) {
            selectedFileID = file.id
            selectedFile = file
        } else {
            deselecteFile()
        }
    }

    func selecteNextFile() -> Bool {
        guard let fileList else { return false }
        guard let selectedFileID else { return false }
        var previous: FileForView?

        for item in fileList {
            if previous?.id == selectedFileID {
                selecteFile(item)
                return true
            }
            previous = item
        }

        return false
    }

    func selectePreviousFile() -> Bool {
        guard let fileList else { return false }
        guard let selectedFileID else { return false }
        var previous: FileForView?

        for item in fileList {
            if item.id == selectedFileID {
                guard let previous else { return false }
                selecteFile(previous)
                return true
            }
            previous = item
        }

        return false
    }
}
