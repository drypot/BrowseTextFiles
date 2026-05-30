//
//  BrowserState+FileList.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {
    // MARK: - File List

    func loadFileList(preserveSelection: Bool = true) {
        LogStore.shared.log("load list: \(selectedFolder?.url.lastPathComponent ?? "nil")")

        let selectedFileURL = selectedFile?.url

        fileList = nil
        selectedFileID = nil
        selectedFile = nil

        do {
            guard let selectedFolder else { return }
            let url = selectedFolder.url
            fileList = try FileListBuilder().collectShallowly(from: url) { contentType in
                // contentType.conforms(to: .text)
                return true
            }
            fileList?.sort {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            LogStore.shared.log("load list: \(message)")
        }

        if preserveSelection, let selectedFileURL {
            selectFile(withURL: selectedFileURL)
        }
    }

    // MARK: - Selected File

    func findFile(with id: FileForView.ID) -> FileForView? {
        guard let fileList else { return nil }
        return fileList.first { $0.id ==  id }
    }

    func deselectFile() {
        selectedFileID = nil
        selectedFile = nil
    }

    func selectFile(_ fileItem: FileForView?) {
        if let fileItem {
            selectedFileID = fileItem.id
            selectedFile = fileItem
        } else {
            deselectFile()
        }
    }

    func selectFile(withID id: FileForView.ID?) {
        if let fileList, let file = fileList.first(where: { $0.id ==  id }) {
            selectedFileID = file.id
            selectedFile = file
        } else {
            deselectFile()
        }
    }

    func selectFile(withURL url: URL) {
        if let fileList, let file = fileList.first(where: { $0.url ==  url }) {
            selectedFileID = file.id
            selectedFile = file
        } else {
            deselectFile()
        }
    }

    func selecteNextFile() -> Bool {
        guard let fileList else { return false }
        guard let selectedFileID else { return false }
        var previous: FileForView?

        for item in fileList {
            if previous?.id == selectedFileID {
                selectFile(item)
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
                selectFile(previous)
                return true
            }
            previous = item
        }

        return false
    }
}
