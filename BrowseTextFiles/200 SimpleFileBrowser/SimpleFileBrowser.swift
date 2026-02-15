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
        let name: String
        let url: URL
        var children: [Folder]?

        init(url: URL) {
            self.id = Self.seed.next()!
            self.url = url
            self.name = url.lastPathComponent
        }
    }

    @State private var rootURL: URL?
    @State private var rootName: String?
    @State private var folders: [Folder] = []
    @State private var selectedFolder: Folder?
    @State private var files: [URL] = []
    @State private var selectedFile: URL?
    @State private var fileContents: String = ""

    var body: some View {
        if rootURL != nil {
            NavigationSplitView {
                List(folders, children: \.children, selection: $selectedFolder) { folder in
                    NavigationLink(folder.name, value: folder)
                }
                .onChange(of: selectedFolder) { oldState, newState in
                    if let folder = newState {
                        do {
                            self.files = try loadFileURLs(from: folder.url)
                        } catch {
                            print("\(error.localizedDescription)")
                            self.files = []
                        }
                        self.selectedFile = nil
                    }
                }
            } content: {
                List(files, id:\.absoluteString, selection: $selectedFile) { file in
                    let fileName = file.lastPathComponent
                    NavigationLink(fileName, value: file)
                }
                // .frame(width: 200)
                .onChange(of: selectedFile) { oldState, newState in
                    if let url = newState {
                        fileContents = loadFile(from: url)
                    }
                }
            } detail: {
                TextEditor(text: $fileContents)
                    .font(.body)
            }
            .toolbarBackground(.hidden) // macOS 26, 툴바 구분선이 나왔다 사라졌다 한다, 강제로 감추는 옵션.
            .navigationTitle(rootName!)
        } else {
            Button("Select Folder") {
                openFolder()
            }
            Button("Select Test Folder") {
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
            prepareFolders(from: url)
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

            if url.startAccessingSecurityScopedResource() {
                prepareFolders(from: url)
                url.stopAccessingSecurityScopedResource()
            }
        } catch {
            print("loadBookmark failed: \(error)")
        }
    }

    func prepareFolders(from url: URL) {
        self.rootURL = url
        self.rootName = url.lastPathComponent
        do {
            let folder = try buildFolderTree(from: url)
            self.folders = [folder]
        } catch {
            self.folders = []
        }
        self.selectedFolder = nil
        self.files = files
        self.selectedFile = nil
        fileContents = ""
    }

    func buildFolderTree(from rootURL: URL) throws -> Folder {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        func buildFolderNode(from url: URL) throws -> Folder {
            let fileManager = FileManager.default
            var folder = Folder(url: url)

            let urls = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: keys,
                options: options
            )

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

    func loadFileURLs(from rootURL: URL) throws -> [URL] {
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        let keys: [URLResourceKey] = [.isRegularFileKey, .contentTypeKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let urls = try fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: keys,
            options: options
        )

        for url in urls {
            try autoreleasepool {
                let values = try url.resourceValues(forKeys: keySet)
                if values.isRegularFile == true,
                   let contentType = values.contentType,
                   contentType.conforms(to: .text) {
                    fileURLs.append(url)
                }
            }
        }

        return fileURLs
    }

    func loadFile(from url: URL) -> String {
        return (try? String(contentsOf: url, encoding: .utf8)) ?? "Can't read file contents"
    }
}

#Preview {
    SimpleFileBrowser()
}
