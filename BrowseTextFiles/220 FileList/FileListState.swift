//
//  FileListState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/2/26.
//

import SwiftUI

@Observable
final class FileListState {
    var folderURL: URL?
    var fileList: [FileState]?
    var selectedFileIDs: Set<FileState.ID> = []
    var scrollToFileID: FileState.ID?

    @ObservationIgnored private(set) var alertState: AlertState

    init(alertState: AlertState) {
        self.alertState = alertState
    }

    func loadFileList(at folderURL: URL?) {
        self.folderURL = folderURL
        reloadFileList(preserveSelection: false)
    }

    func reloadFileList(preserveSelection: Bool = true) {
        guard let folderURL else { return }

        consoleLog("load filelist: \(folderURL.path(percentEncoded: false))")
        do {
            fileList = try FileState.collectShallowly(from: folderURL) { contentType in
                // contentType.conforms(to: .text)
                return true
            }
            fileList?.sort {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            if !preserveSelection {
                selectedFileIDs.removeAll()
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("load filelist: \(message)")
        }
    }

    func selectFile(with id: FileState.ID?) {
        if let id {
            selectedFileIDs = [id]
        } else {
            selectedFileIDs.removeAll()
        }
    }

    func trashFiles(selection: Set<FileState.ID>) {
        selectedFileIDs.subtract(selection)
        fileList?.removeAll(where: { selection.contains($0.id) })
        do {
            let fileManager = FileManager.default
            for url in selection {
                consoleLog("delete file: \(url.path(percentEncoded: false))")
                try fileManager.trashItem(at: url, resultingItemURL: nil)
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("delete file: \(message)")
        }
    }

    /*
    List 수작업으로 만들었을 때 쓰던 코드.

    func selecteNextFile() -> Bool {
        guard let fileList else { return false }
        guard let selectedFileID else { return false }
        var previous: FileState?

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
        var previous: FileState?

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
    */
}
