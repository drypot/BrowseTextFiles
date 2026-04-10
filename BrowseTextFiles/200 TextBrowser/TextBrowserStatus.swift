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

    func openFolder(at url: URL) {
        do {
            reset()
            try withSecurityScope(url) {
                let folder = try FolderTreeBuilder().build(from: url)
                rootURL = url
                rootFolder = folder
                folders = [folder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
                selectedFolder = folder
            }
            refreshFiles()
        } catch {
            print("openFolderURL: \(error.localizedDescription)")
        }
    }

    func reload() {
        do {
            let savedRootURL = rootURL
            let savedFolderURL = selectedFolder?.url
            let savedFileURL = selectedFileURL

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
            openSelectedFile()
        } catch {
            print("reload: \(error.localizedDescription)")
        }
    }

    // MARK: - Files

    func refreshFiles() {
        do {
            guard let rootURL else { return }
            guard let selectedFolderURL = selectedFolder?.url else { return }
            //print("refreshFiles: \(selectedFolderURL)")
            try withSecurityScope(rootURL) {
                fileURLs = try TextFileURLCollector().collectShallowly(from: selectedFolderURL)
                fileURLs?.sort { $0.lastPathComponent < $1.lastPathComponent }
                selectedFileURL = nil
            }
        } catch {
            print("refreshFiles: \(error.localizedDescription)")
        }
    }

    func openSelectedFile() {
        guard let url = selectedFileURL else { return }

        // prepare to change buffer
        // 파일 저장이라든지 ...

        if let buffer = TextBufferCache.shared.buffer(for: url) {
            self.buffer = buffer
            print("openSelectedFile: found in cache")
            return
        }

        do {
            guard let rootURL = rootFolder?.url else { return }
            try withSecurityScope(rootURL) {
                let buffer = try TextBufferCache.shared.addCache(for: url)
                self.buffer = buffer
            }
            print("openSelectedFile: added new")
        } catch {
            print("openSelectedFile: \(error.localizedDescription)")
        }
    }
}

