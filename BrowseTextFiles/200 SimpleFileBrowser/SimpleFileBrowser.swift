//
//  SimpleFileBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

struct SimpleFileBrowser: View {
    @State private var rootFolder: URL?
    @State private var folders: [URL] = []
    @State private var selectedFolder: URL?
    @State private var files: [URL] = []
    @State private var selectedFile: URL?
    @State private var fileContents: String = ""

    var body: some View {
        if rootFolder != nil {
            NavigationSplitView {
                List(folders, id: \.absoluteString, selection: $selectedFolder) { folder in
                    let folderName = folder.lastPathComponent
                    NavigationLink(folderName, value: folder)
                }
                .onChange(of: selectedFolder) { oldState, newState in
                    if let url = newState {
                        let (folders, files) = loadFolderContents(from: url)
                        self.folders = folders
                        self.selectedFolder = nil
                        self.files = files
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
            .navigationTitle("NavigationSplit by Value Demo")
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
        self.rootFolder = url
        let (folders, files) = loadFolderContents(from: url)

        self.folders = folders
        self.selectedFolder = nil
        self.files = files
        self.selectedFile = nil
        fileContents = ""
    }

    func loadFolderContents(from url: URL) -> (folders: [URL], files: [URL]) {
        let fileManager = FileManager.default
        var folders: [URL] = []
        var files: [URL] = []

        let keys: [URLResourceKey] = [.isDirectoryKey, .contentTypeKey]
        let keySet = Set(keys)

        do {
            let items = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: .skipsHiddenFiles)

            for item in items {
                let resourceValues = try item.resourceValues(forKeys: keySet)

                if let isDirectory = resourceValues.isDirectory, isDirectory {
                    folders.append(item)
                    continue
                }

                if let contentType = resourceValues.contentType {
                    if contentType.conforms(to: .text) {
                        files.append(item)
                    }
                    continue
                }
            }
        } catch {
            print("\(error.localizedDescription)")
        }

        return (folders, files)
    }

    func loadFile(from url: URL) -> String {
        return (try? String(contentsOf: url, encoding: .utf8)) ?? "Can't read file contents"
    }
}

#Preview {
    SimpleFileBrowser()
}
