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

    private let log = LogStore.shared.log

    // MARK: - Root & Folders

    var isReady: Bool {
        return rootFolder != nil
    }

    private func reset() {
        rootURL = nil
        rootFolder = nil

        folders = nil
        selectedFolder = nil

        fileURLs = nil
        selectedFileURL = nil

        buffer = nil
    }

    func openFolder(at url: URL, fileURL: URL? = nil) {
        do {
            reset()
            try withSecurityScope(url) {
                let folder = try FolderTreeBuilder().build(from: url)
                rootURL = url
                rootFolder = folder
                folders = [folder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
                selectedFolder = folder
                if let fileURL {
                    let folderURL = fileURL.deletingLastPathComponent()
                    if let found = folder.findChild(with: folderURL) {
                        selectedFolder = found
                    }
                }
            }
            refreshFiles()
            if let fileURL {
                selectedFileURL = fileURL
                openFile()
            }
        } catch {
            log("openFolderURL: \(error.localizedDescription)")
        }
    }

    func reload() {
        do {
            let savedRootURL = rootURL
            let savedFolderURL = selectedFolder?.url
            let savedFileURL = selectedFileURL

            TextBufferCache.shared.reset()
            reset()

            guard let url = savedRootURL else { return }
            try withSecurityScope(url) {
                let folder = try FolderTreeBuilder().build(from: url)
                rootURL = url
                rootFolder = folder
                folders = [folder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
                selectedFolder = folder
                if let savedFolderURL {
                    if let found = folder.findChild(with: savedFolderURL) {
                        selectedFolder = found
                    }
                }
            }
            refreshFiles()
            if let fileURLs, let savedFileURL, fileURLs.contains(savedFileURL) {
                selectedFileURL = savedFileURL
            }
            openFile()
        } catch {
            log("reload: \(error.localizedDescription)")
        }
    }

    // MARK: - Files

    func refreshFiles() {
        do {
            guard let rootURL else { return }
            guard let selectedFolderURL = selectedFolder?.url else { return }
            //log("refreshFiles: \(selectedFolderURL)")
            try withSecurityScope(rootURL) {
                fileURLs = try TextFileURLCollector().collectShallowly(from: selectedFolderURL)
                fileURLs?.sort { $0.lastPathComponent < $1.lastPathComponent }
                selectedFileURL = nil
            }
        } catch {
            log("refreshFiles: \(error.localizedDescription)")
        }
    }

    func openFile() {
        guard let rootURL else { return }
        guard let url = selectedFileURL else { return }

        saveFile()

        do {
            self.buffer = try TextBufferCache.shared.buffer(for: url, rootURL: rootURL)
        } catch {
            log("openFile: \(error.localizedDescription)")
        }
    }

    func saveFile() {
        guard let rootURL else { return }
        guard let buffer, buffer.isEdited else { return }
        do {
            try TextBufferCache.shared.saveBuffer(buffer, rootURL: rootURL)
        } catch {
            log("saveFile: \(error.localizedDescription)")
        }
    }
}

