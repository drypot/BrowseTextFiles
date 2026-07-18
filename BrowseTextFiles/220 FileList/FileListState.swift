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

    @ObservationIgnored private var context: BrowserContext

    init(context: BrowserContext) {
        self.context = context
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
            context.leaveAlert(message)
            consoleLog("load file list: \(message)")
        }
    }

    func loadFileList() {
        loadFileList(at: context.selectedFolderURL)
    }

    func trashFiles(selection: Set<FileState.ID>) {
        do {
            let fileManager = FileManager.default
            for url in selection {
                consoleLog("delete file: \(url.path(percentEncoded: false))")
                try fileManager.trashItem(at: url, resultingItemURL: nil)
            }
            loadFileList()
            if let selectedFileURL = context.selectedFileURL {
                if selection.contains(selectedFileURL) {
                    context.selectedFileURL = nil
                }
            }
        } catch {
            let message = error.localizedDescription
            context.leaveAlert(message)
            consoleLog("delete file: \(message)")
        }
    }

}
