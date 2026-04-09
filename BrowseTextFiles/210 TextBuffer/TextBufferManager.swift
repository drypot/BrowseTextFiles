//
//  TextBufferManager.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MyLibrary

@Observable
final class TextBufferManager {
    private(set) var rootURL: URL?
    private(set) var rootFolder: Folder?

    private(set) var folders: [Folder] = []
    var selectedFolder: Folder?

    private(set) var fileURLs: [URL] = []
    var selectedFileURL: URL?

    public private(set) var buffer: TextBuffer?

    public init() {}

    // MARK: - Root & Folders

    var isReady: Bool {
        return rootFolder != nil
    }

    func openFolder(at rootURL: URL) {
        do {
            try withSecurityScope(rootURL) {
                let folder = try FolderTreeBuilder().build(from: rootURL)
                self.rootURL = rootURL
                rootFolder = folder
                folders = [folder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
                selectedFolder = folder
            }
            refreshFiles()
            releaseBuffer()
        } catch {
            print("openFolderURL: \(error.localizedDescription)")
        }
    }

    func reload() {
        do {
            guard let rootURL else { return }
            let savedFolderURL = selectedFolder?.url
            let savedFileURL = selectedFileURL
            try withSecurityScope(rootURL) {
                let folder = try FolderTreeBuilder().build(from: rootURL)
                rootFolder = folder
                folders = [folder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
                if let savedFolderURL {
                    if let found = folder.findChild(with: savedFolderURL) {
                        selectedFolder = found
                    } else {
                        selectedFolder = folder
                    }
                } else {
                    selectedFolder = folder
                }
            }
            refreshFiles()
            releaseBuffer()
            if fileURLs.contains(where: { $0 == savedFileURL }) {
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
            print("refreshFiles: \(selectedFolderURL)")
            try withSecurityScope(rootURL) {
                fileURLs = try TextFileURLCollector().collectShallowly(from: selectedFolderURL)
                fileURLs.sort { $0.lastPathComponent < $1.lastPathComponent }
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
            releaseBuffer()
            allocBuffer(buffer)
            return
        }

        do {
            guard let rootURL = rootFolder?.url else { return }
            try withSecurityScope(rootURL) {
                let buffer = try TextBufferCache.shared.addCache(for: url)
                releaseBuffer()
                allocBuffer(buffer)

//            withObservationTracking {
//                _ = buffer.isValid
//            } onChange: {
//                Task { @MainActor in
//                    let buffer = Self.bufferDic.removeValue(forKey: url)
//                    buffer?.stopMonitoring()
//                }
//            }
//            buffer.startMonitoring()

            }
        } catch {
            print("openSelectedFile: \(error.localizedDescription)")
        }
    }

    func releaseBuffer() {
        guard let buffer else { return }
        buffer.refCount -= 1
        self.buffer = nil
    }

    func allocBuffer(_ buffer: TextBuffer) {
        buffer.refCount += 1
        self.buffer = buffer
    }

    // MARK: - Buffers

//    private func addBuffer(contentOf url: URL) -> TextBuffer? {
//        do {
//            guard let rootURL = root?.url else { return nil }
//            let securityScoped = rootURL.startAccessingSecurityScopedResource()
//            defer { if securityScoped { rootURL.stopAccessingSecurityScopedResource() } }
//
//            let buffer = try TextBuffer(contentsOf: url)
//            Self.bufferDic[url] = buffer
//
//            withObservationTracking {
//                _ = buffer.isValid
//            } onChange: {
//                Task { @MainActor in
//                    let buffer = Self.bufferDic.removeValue(forKey: url)
//                    buffer?.stopMonitoring()
//                }
//            }
//            buffer.startMonitoring()
//
//            return buffer
//        } catch {
//            print("file open failed: \(error.localizedDescription)")
//        }
//        return nil
//    }
    
}

