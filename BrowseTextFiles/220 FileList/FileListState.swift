//
//  FileListState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/2/26.
//

import SwiftUI

@Observable
final class FileListState {
    var fileList: [FileState]?
    var refreshCount = 0

    @ObservationIgnored private var browserState: BrowserState

    init(browserState: BrowserState) {
        self.browserState = browserState
    }

    func loadFileList(at folderURL: URL?) {
        fileList = nil

        guard let folderURL else { return }

        consoleLog("load file list: \(folderURL.path(percentEncoded: false))")
        do {
            fileList = try FileState.collectShallowly(from: folderURL) { contentType in
                // contentType.conforms(to: .text)
                return true
            }
            fileList?.sort {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            refreshCount += 1
            consoleLog("----")
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("load file list: \(message)")
        }
    }

    func loadFileList() {
        loadFileList(at: browserState.selectedFolderURL)
    }

    func trashFiles(selection: Set<FileState.ID>) {
        fileList?.removeAll { selection.contains($0.id) }
        if let selectedFileURL = browserState.selectedFileURL, selection.contains(selectedFileURL) {
            browserState.selectedFileURL = nil
        }
        do {
            let fileManager = FileManager.default
            for url in selection {
                consoleLog("delete file: \(url.path(percentEncoded: false))")
                try fileManager.trashItem(at: url, resultingItemURL: nil)
            }
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("delete file: \(message)")
        }
    }

}
