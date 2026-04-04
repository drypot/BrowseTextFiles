//
//  TextBufferManager.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MyLibrary

@MainActor @Observable
class TextBufferManager {
    @MainActor private static var bufferDic: [URL: TextBuffer] = [:]

    private(set) var root: Folder?

    private(set) var folders: [Folder] = []
    var selectedFolder: Folder?

    private(set) var files: [URL] = []
    var selectedFile: URL?

    public private(set) var buffer: TextBuffer?

    public init() {}

    // MARK: - Root & Folders

    func setRoot(to url: URL) {
        do {
            let securityScoped = url.startAccessingSecurityScopedResource()
            defer { if securityScoped { url.stopAccessingSecurityScopedResource() } }
            
            let folder = try FolderTreeBuilder().build(from: url)
            root = folder
            folders = [folder]  // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
            selectedFolder = folder
            updateFiles()
        } catch {
            print("folder list update failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Files

    func updateFiles() {
        do {
            guard let selectedFolderURL = selectedFolder?.url else { return }
            guard let rootURL = root?.url else { return }

            let securityScoped = rootURL.startAccessingSecurityScopedResource()
            defer { if securityScoped { rootURL.stopAccessingSecurityScopedResource() } }

            files = try TextFileURLCollector().collectShallowly(from: selectedFolderURL)
            files.sort { $0.lastPathComponent < $1.lastPathComponent }
            selectedFile = nil
        } catch {
            print("file list update failed: \(error.localizedDescription)")
        }
    }

    func openSelectedFile() {
        guard let url = selectedFile else { return }

        // prepare to change buffer
        // 파일 저장이라든지 ...

        if let buffer = Self.bufferDic[url] {
            self.buffer = buffer
        } else if let buffer = addBuffer(contentOf: url) {
            self.buffer = buffer
        }
    }

    // MARK: - Buffers

    private func addBuffer(contentOf url: URL) -> TextBuffer? {
        do {
            guard let rootURL = root?.url else { return nil }
            let securityScoped = rootURL.startAccessingSecurityScopedResource()
            defer { if securityScoped { rootURL.stopAccessingSecurityScopedResource() } }

            let buffer = try TextBuffer(contentsOf: url)
            Self.bufferDic[url] = buffer

            return buffer
        } catch {
            print("file open failed: \(error.localizedDescription)")
        }
        return nil
    }
}

