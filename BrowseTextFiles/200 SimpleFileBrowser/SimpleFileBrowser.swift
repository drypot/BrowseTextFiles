//
//  SimpleFileBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

struct SimpleFileBrowser: View {
    struct Folder: Identifiable, Hashable {
        private static var seed = IntSequence().makeIterator()

        let id: Int
        let url: URL
        let name: String
        var children: [Folder]?

        init(url: URL) {
            self.id = Self.seed.next()!
            self.url = url
            self.name = url.lastPathComponent
        }
    }

    struct File: Identifiable, Hashable {
        private static var seed = IntSequence().makeIterator()

        let id: Int
        let url: URL
        let name: String

        init(url: URL) {
            self.id = Self.seed.next()!
            self.url = url
            self.name = url.lastPathComponent
        }
    }

    @State private var rootURL: URL?
    @State private var rootName: String = ""
    @State private var folders: [Folder] = []
    @State private var selectedFolder: Folder?
    @State private var files: [File] = []
    @State private var selectedFile: File?
    @State private var buffers: [FileBuffer] = []
    @State private var selectedBuffer: FileBuffer?

    @Environment(FileBufferManager.self) var bufferManager
    @Environment(SettingsModel.self) var settings

    var body: some View {
        if rootURL != nil {
            NavigationSplitView {
                List(folders, children: \.children, selection: $selectedFolder) { folder in
                    NavigationLink(folder.name, value: folder)
                }
            } content: {
                List(files, selection: $selectedFile) { file in
                    NavigationLink(file.name, value: file)
                }
            } detail: {
                TabView(selection: $selectedBuffer) {
                    ForEach(buffers) { buffer in
                        @Bindable var buffer = buffer
                        TextEditor(text: $buffer.text)
                            .font(.custom(settings.fontName, size: settings.fontSize))
                            .lineSpacing(settings.lineSpacing)
                            .tabItem {
                                Text(buffer.name)
                            }
                            .tag(buffer)
                    }
                }
                .padding()
            }
//            .toolbarBackground(.hidden) // macOS 26, 툴바 구분선이 나왔다 사라졌다 한다, 강제로 감추는 옵션.
            .navigationTitle(rootName)
            .onChange(of: selectedFolder) {
                updateFiles()
            }
            .onChange(of: selectedFile) {
                openFile()
            }
        } else {
            Button("Open Folder") {
                openFolder()
            }
            Button("Open Last Folder") {
                openLastFolder()
            }
        }
    }

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            saveBookmark(from: url)
            setRootURL(to: url)
        }
    }

    func saveBookmark(from url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: "lastOpenFolder")
        } catch {
            print("saveBookmark failed: \(error)")
        }
    }

    func openLastFolder() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "lastOpenFolder") else { return }

        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData,
                              options: .withSecurityScope,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            if isStale {
                saveBookmark(from: url)
            }
            setRootURL(to: url)
        } catch {
            print("loadBookmark failed: \(error)")
        }
    }

    func setRootURL(to url: URL) {
        self.rootURL = url
        self.rootName = url.lastPathComponent
        self.folders = []
        self.selectedFolder = nil
        self.files = []
        self.selectedFile = nil
        self.buffers = []
        self.selectedBuffer = nil

        guard self.rootURL!.startAccessingSecurityScopedResource() else { return }
        defer { self.rootURL!.stopAccessingSecurityScopedResource() }

        if let folder = try? buildFolderTree(from: url) {
            self.folders.append(folder)
        }

        self.selectedFolder = self.folders.first
        updateFiles()
    }

    func buildFolderTree(from rootURL: URL) throws -> Folder {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        func buildFolderNode(from url: URL) throws -> Folder {
            let fileManager = FileManager.default
            var folder = Folder(url: url)

            var urls = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: keys,
                options: options
            )
            urls.sort { $0.lastPathComponent < $1.lastPathComponent }

            for url in urls {
                try autoreleasepool {
                    let values = try url.resourceValues(forKeys: keySet)
                    if values.isDirectory == true {
                        let childFolder = try buildFolderNode(from: url)
                        if folder.children == nil {
                            folder.children = [childFolder]
                        } else {
                            folder.children!.append(childFolder)
                        }
                    }
                }
            }

            return folder
        }

        return try buildFolderNode(from: rootURL)
    }

    func updateFiles() {
        if let folder = self.selectedFolder {
            self.files = (try? loadFiles(from: folder.url)) ?? []
            self.selectedFile = nil
        }
    }

    func loadFiles(from folderURL: URL) throws -> [File] {
        let fileManager = FileManager.default
        var files: [File] = []

        let keys: [URLResourceKey] = [.isRegularFileKey, .contentTypeKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        guard self.rootURL!.startAccessingSecurityScopedResource() else { return [] }
        defer { self.rootURL!.stopAccessingSecurityScopedResource() }

        var urls = try fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: keys,
            options: options
        )
        urls.sort { $0.lastPathComponent < $1.lastPathComponent }

        for url in urls {
            try autoreleasepool {
                let values = try url.resourceValues(forKeys: keySet)
                if values.isRegularFile == true,
                   let contentType = values.contentType,
                   contentType.conforms(to: .text) {
                    files.append(File(url: url))
                }
            }
        }

        return files
    }

    func openFile() {
        if let file = selectedFile {
            if let buffer = (buffers.first { $0.url == file.url }) {
                selectedBuffer = buffer
            } else if let buffer = bufferManager.buffer(for: file.url) {
                buffer.refCount += 1
                buffers.append(buffer)
                selectedBuffer = buffer
            } else {
                do {
                    guard self.rootURL!.startAccessingSecurityScopedResource() else { throw AppError.fileOpenError }
                    defer { self.rootURL!.stopAccessingSecurityScopedResource() }
                    let buffer = try bufferManager.addBuffer(for: file.url)
                    buffers.append(buffer)
                    selectedBuffer = buffer
                } catch {
                    print("Can't read file contents")
                }
            }
        }
    }
}

#Preview {
    SimpleFileBrowser()
}
