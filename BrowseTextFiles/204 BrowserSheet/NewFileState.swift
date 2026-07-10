//
//  NewFileState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/6/26.
//

import SwiftUI

@Observable
final class NewFileState {
    private(set) var relativePath: String?
    private var onComplete: ((URL?, URL) -> Void)?

    var isNewFileSheetPresented = false

    @ObservationIgnored private var rootState: RootState
    @ObservationIgnored private var alertState: AlertState

    init(rootState: RootState, alertState: AlertState) {
        self.rootState = rootState
        self.alertState = alertState
    }

    func showNewFileSheet(on folderURL: URL, onComplete: @escaping (URL?, URL) -> Void) {
        guard let rootURL = rootState.rootURL else { return }
        guard let relativePath = folderURL.relativePath(from: rootURL) else { return }
        self.relativePath = relativePath
        self.onComplete = onComplete
        self.isNewFileSheetPresented = true
    }

    func makeNewFile(with newFilePath: String) {
        guard let rootURL = rootState.rootURL else { return }
        let fileManager = FileManager.default
        let newFileURL = rootURL.appending(path: newFilePath).standardizedFileURL
        var newFolderURL: URL? = nil
        do {
            if !fileManager.fileExists(atPath: newFileURL.path(percentEncoded: false)) {
                let folderURL = newFileURL.deletingLastPathComponent()
                if !fileManager.fileExists(atPath: folderURL.path(percentEncoded: false)) {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    newFolderURL = folderURL
                }
                consoleLog("new file: \(newFileURL.path(percentEncoded: false))")
                try "".write(to: newFileURL, atomically: true, encoding: .utf8)
            }
            onComplete?(newFolderURL, newFileURL)
        } catch {
            let message = error.localizedDescription
            alertState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    func makeNewFile(in folderURL: URL, onComplete: @escaping (URL) -> Void) {
        let fileManager = FileManager.default
        var newFileURL = folderURL.appending(path: "Untitled.md", directoryHint: .notDirectory)
        var counter = 1

        while fileManager.fileExists(atPath: newFileURL.path(percentEncoded: false)), counter < 100 {
            let newName = "Untitled \(counter).md"
            newFileURL = folderURL.appending(path: newName, directoryHint: .notDirectory)
            counter += 1
        }

        do {
            consoleLog("new file: \(newFileURL.path(percentEncoded: false))")
            try "".write(to: newFileURL, atomically: true, encoding: .utf8)
            onComplete(newFileURL)
        } catch {
            let message = error.localizedDescription
            alertState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }
}
