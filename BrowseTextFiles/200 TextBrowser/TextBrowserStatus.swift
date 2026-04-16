//
//  TextBrowserStatus.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MyLibrary

@Observable
final class TextBrowserStatus {
    private(set) var rootURL: URL?
    private(set) var rootFolder: Folder?

    private(set) var folders: [Folder]?
    var selectedFolder: Folder?

    private(set) var fileURLs: [URL]?
    var selectedFileURL: URL?

    private(set) var buffer: TextBuffer?
    private var fileMonitor: FileMonitor?

    private let log = LogStore.shared.log

    var isReady: Bool {
        return rootFolder != nil
    }

    private func resetStatus() {
        rootURL = nil
        rootFolder = nil

        folders = nil
        selectedFolder = nil

        fileURLs = nil
        selectedFileURL = nil

        buffer = nil
    }

    func loadRoot(from rootURL: URL) {
        do {
            resetStatus()
            try withSecurityScope(rootURL) {
                let folder = try FolderTreeBuilder().build(from: rootURL)
                self.rootURL = rootURL
                rootFolder = folder
                folders = [folder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
            }
        } catch {
            log("loadRoot: \(error.localizedDescription)")
        }
    }

    func loadFolder(from folder: Folder) {
        selectedFolder = folder
        loadSelectedFolder()
    }

    func loadRootFolder() {
        selectedFolder = rootFolder
        loadSelectedFolder()
    }

    func loadSelectedFolder() {
        guard let rootURL else { return }
        guard let folder = selectedFolder else { return }
        do {
            try withSecurityScope(rootURL) {
                fileURLs = try TextFileURLCollector().collectShallowly(from: folder.url)
                fileURLs?.sort { $0.lastPathComponent < $1.lastPathComponent }
            }
        } catch {
            log("loadSelectedFolder: \(error.localizedDescription)")
        }
    }

    func loadFile(from url: URL) {
        guard let rootFolder else { return }
        let folderURL = url.deletingLastPathComponent()
        guard let folder = rootFolder.findChild(with: folderURL) else { return }
        loadFolder(from: folder)
        if let fileURLs, fileURLs.contains(url) {
            selectedFileURL = url
            loadSelectedFile()
        }
    }

    func reloadAll() {
        guard let rootURL else { return }
        let savedFileURL = selectedFileURL

        loadRoot(from: rootURL)
        if let savedFileURL {
            loadFile(from: savedFileURL)
        }
    }

    func loadSelectedFile() {
        guard let rootURL else { return }
        guard let url = selectedFileURL else { return }
        do {
            self.buffer = nil
            self.fileMonitor = nil
            try withSecurityScope(rootURL) {
                let buffer = TextBuffer(url: url)
                try buffer.loadContent()
                self.buffer = buffer

                self.fileMonitor = FileMonitor()
                fileMonitor?.startMonitoring(url) { [weak self] _ in
                    guard let self else { return }
                    self.loadSelectedFile()
                }
            }
        } catch {
            log("openFile: \(error.localizedDescription)")
        }
    }

    func saveFile() {
        guard let rootURL else { return }
        guard let buffer, buffer.isEdited else { return }
        do {
            try withSecurityScope(rootURL) {
                try fileMonitor?.disableMonitoringWhile {
                    try buffer.saveContent()
                }
            }
        } catch {
            log("saveFile: \(error.localizedDescription)")
        }
    }
}

