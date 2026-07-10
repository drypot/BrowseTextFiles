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

    @ObservationIgnored private var targetState: TargetState
    @ObservationIgnored private(set) var alertState: AlertState

    init(targetState: TargetState, alertState: AlertState) {
        self.targetState = targetState
        self.alertState = alertState
    }

    func loadFileList(at folderURL: URL?) {
        guard let folderURL = targetState.selectedFolderURL else {
            fileList = nil
            return
        }

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
            alertState.leaveAlert(message)
            consoleLog("load file list: \(message)")
        }
    }

    func trashFiles(selection: Set<FileState.ID>) {
        fileList?.removeAll(where: { selection.contains($0.id) })
        do {
            let fileManager = FileManager.default
            for url in selection {
                consoleLog("delete file: \(url.path(percentEncoded: false))")
                try fileManager.trashItem(at: url, resultingItemURL: nil)
            }
        } catch {
            let message = error.localizedDescription
            alertState.leaveAlert(message)
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
