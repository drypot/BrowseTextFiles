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
    var selectedFileID: FileState.ID?
    var selectedFile: FileState?
    private var savedSelectedFileURL: URL?

    @ObservationIgnored
    private(set) var alertState: AlertState

    init(alertState: AlertState) {
        self.alertState = alertState
    }

    func loadFileList(at folderURL: URL?, preserveSelection: Bool = true) {
        self.folderURL = folderURL
        guard let folderURL else { return }

        consoleLog("load filelist: \(folderURL.lastPathComponent)")

        saveSelection()
        reset()

        do {
            fileList = try FileState.collectShallowly(from: folderURL) { contentType in
                // contentType.conforms(to: .text)
                return true
            }
            fileList?.sort {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("load filelist: \(message)")
        }

        if preserveSelection {
            restoreSelection()
        }
    }

    func reset() {
        fileList = nil
        selectedFileID = nil
        selectedFile = nil
    }

    func saveSelection() {
        savedSelectedFileURL = selectedFile?.url
    }

    func restoreSelection() {
        guard let savedSelectedFileURL else { return }
        selectFile(with: savedSelectedFileURL)
    }

    func selectFile(_ fileItem: FileState?) {
        if let fileItem {
            selectedFileID = fileItem.id
            selectedFile = fileItem
        } else {
            deselectFile()
        }
    }

    func selectFile(with id: FileState.ID?) {
        if let fileList, let file = fileList.first(where: { $0.id ==  id }) {
            selectedFileID = file.id
            selectedFile = file
        } else {
            deselectFile()
        }
    }

    // 현재는 ID 가 URL 인데 추후 변경될 경우를 대비해서 두 selectFile 모두 유지해 두기로 한다.
    func selectFile(with url: URL) {
        if let fileList, let file = fileList.first(where: { $0.url ==  url }) {
            selectedFileID = file.id
            selectedFile = file
        } else {
            deselectFile()
        }
    }

    func deselectFile() {
        selectedFileID = nil
        selectedFile = nil
    }

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

    func trashFile(at url: URL) {
        do {
            let fileManager = FileManager.default

            let deletingSelectedFile = selectedFile?.url == url

            consoleLog("deleting file: \(url.path(percentEncoded: false))")
            try fileManager.trashItem(at: url, resultingItemURL: nil)
            if deletingSelectedFile {
                loadFileList(at: folderURL, preserveSelection: false)
            } else {
                loadFileList(at: folderURL)
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("delete file: \(message)")
        }
    }

}
