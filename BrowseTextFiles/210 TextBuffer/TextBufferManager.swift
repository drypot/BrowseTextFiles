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
    @MainActor private static var sharedDic: [URL: TextBuffer] = [:]

    private(set) var root: Folder?

    private(set) var folders: [Folder] = []
    var selectedFolder: Folder?

    private(set) var files: [URL] = []
    var selectedFile: URL?

    public private(set) var buffers: [TextBuffer] = []
    var selectedBuffer: TextBuffer?

    private var bufferDic: [URL: TextBuffer] = [:]

    public init() {}

    // MARK: - Root & Folders

    func setRoot(to url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let folder = try FolderTreeBuilder().build(from: url)
            root = folder
            // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
            folders = [folder]
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

            let accessing = rootURL.startAccessingSecurityScopedResource()
            defer { if accessing { rootURL.stopAccessingSecurityScopedResource() } }

            files = try TextFileURLCollector().collectShallowly(from: selectedFolderURL)
            files.sort { $0.lastPathComponent < $1.lastPathComponent }
            selectedFile = nil
        } catch {
            print("file list update failed: \(error.localizedDescription)")
        }
    }

    func openSelectedFile() {
        do {
            guard let selectedFileURL = selectedFile else { return }
            guard let rootURL = root?.url else { return }
            if let file = buffer(for: selectedFileURL) {
                selectedBuffer = file
            } else {
                let accessing = rootURL.startAccessingSecurityScopedResource()
                defer { if accessing { rootURL.stopAccessingSecurityScopedResource() } }
                selectedBuffer = try addBuffer(contentOf: selectedFileURL)
            }
        } catch {
            print("file open failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Buffers

    public func buffer(for url: URL) -> TextBuffer? {
        if let buffer = bufferDic[url] {
            return buffer
        } else if let buffer = Self.sharedDic[url] {
            buffer.refCount += 1
            buffers.append(buffer)
            bufferDic[url] = buffer
            return buffer
        } else {
            return nil
        }
    }

    public func addBuffer(contentOf url: URL) throws -> TextBuffer {
        let text = try String(contentsOf: url, encoding: .utf8)
        let buffer = TextBuffer(url: url, text: text)

        Self.sharedDic[url] = buffer

        buffer.refCount += 1
        buffers.append(buffer)
        bufferDic[url] = buffer

        return buffer
    }
}

