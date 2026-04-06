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
    private(set) var rootFolder: Folder?

    private(set) var folders: [Folder] = []
    var selectedFolder: Folder?

    private(set) var files: [URL] = []
    var selectedFile: URL?

    public private(set) var buffer: TextBuffer?

//    private var  securityScopedList: [Bool] = []

    public init() {}

    // MARK: - Root & Folders

    var isReady: Bool {
        return rootFolder != nil
    }

    var rootURL: URL? {
        return rootFolder?.url
    }

//    func startAcessingRoot() {
//        if let url = rootURL {
//            let securityScoped = url.startAccessingSecurityScopedResource()
//            securityScopedList.append(securityScoped)
//            print("startAcessingRoot: \(securityScoped), \(securityScopedList.count)")
//        }
//    }
//
//    func stopAcessingRoot() {
//        if let url = rootURL {
//            if securityScopedList.removeLast() {
//                url.stopAccessingSecurityScopedResource()
//                print("stopAcessingRoot: \(true), \(securityScopedList.count)")
//            } else {
//                print("stopAcessingRoot: \(false), \(securityScopedList.count)")
//            }
//        }
//    }

    func openURL(_ url: URL) {
        openFolderURL(url)

//        do {
//            let values = try url.resourceValues(forKeys: [.isDirectoryKey])
//            if let isDirectory = values.isDirectory {
//                if isDirectory {
//                    openFolderURL(url)
//                } else {
//                     openFileURL(url)
//                }
//            }
//        } catch {
//            print("openURL: \(error.localizedDescription)")
//        }

    }

    private func openFolderURL(_ url: URL) {
        do {
            try withSecurityScope(url) {
                let folder = try FolderTreeBuilder().build(from: url)
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

//    private func openFileURL(_ url: URL) {
//        do {
//            let rootURL = url.deletingLastPathComponent()
//            let _ = SecurityScope(for: url)
//
//            print("aa")
//            let folder = try FolderTreeBuilder().build(from: rootURL)
//            print("bb")
//            rootFolder = folder
//            folders = [folder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
//            selectedFolder = folder
//            refreshFiles()
//            selectedFile = url
//            openSelectedFile()
//        } catch {
//            print("openFileURL: failed, \(error.localizedDescription)")
//        }
//    }

    func reload() {
        let name = rootFolder?.name ?? "unknown"
        print("buffer manager: refresh, \(name)")
    }

    // MARK: - Files

    func refreshFiles() {
        do {
            guard let selectedFolderURL = selectedFolder?.url else { return }
            guard let rootURL = rootFolder?.url else { return }
            try withSecurityScope(rootURL) {
                files = try TextFileURLCollector().collectShallowly(from: selectedFolderURL)
                files.sort { $0.lastPathComponent < $1.lastPathComponent }
                selectedFile = nil
            }
        } catch {
            print("refreshFiles: \(error.localizedDescription)")
        }
    }

    func openSelectedFile() {
        guard let url = selectedFile else { return }

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

