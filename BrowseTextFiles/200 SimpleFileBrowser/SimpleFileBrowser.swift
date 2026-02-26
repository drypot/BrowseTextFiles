//
//  SimpleFileBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

struct SimpleFileBrowser: View {
    @State private var folderListManager = FolderListManager()
    @State private var selectedFolder: Folder?

    @State private var fileListManager = FileListManager()
    @State private var selectedFile: File?

    @State private var buffers: [FileBuffer] = []
    @State private var selectedBuffer: FileBuffer?

    @Environment(GlobalBufferManager.self) var globalBufferManager
    @Environment(SettingsData.self) var settings

    var body: some View {
        if let root = folderListManager.root {
            NavigationSplitView {
                List(folderListManager.folders, children: \.folders, selection: $selectedFolder) { folder in
                    NavigationLink(folder.name, value: folder)
                }
            } content: {
                List(fileListManager.files, selection: $selectedFile) { file in
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
            .navigationTitle(root.name)
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
            openFolder(from: url)
            BookmarkManager.shared.save(url, forKey: "lastOpenFolder")
        }
    }

    func openFolder(from url: URL) {
        folderListManager.setRoot(to: url)
        selectedFolder = folderListManager.root
        updateFiles()
    }

    func openLastFolder() {
        if let url = BookmarkManager.shared.load(forKey: "lastOpenFolder") {
            openFolder(from: url)
        }
    }

    func updateFiles() {
        if let selectedFolderURL = selectedFolder?.url,
           let rootURL = folderListManager.root?.url {
            do {
                try fileListManager.update(from: selectedFolderURL, root: rootURL)
                selectedFile = nil
            } catch {
                print("\(error.localizedDescription)")
            }
        }
    }

    func openFile() {
        if let selectedFile {
            if let buffer = (buffers.first { $0.url == selectedFile.url }) {
                selectedBuffer = buffer
            } else if let buffer = globalBufferManager.buffer(for: selectedFile.url) {
                buffer.refCount += 1
                buffers.append(buffer)
                selectedBuffer = buffer
            } else {
                do {
                    guard let root = folderListManager.root else { fatalError("root is null") }
                    guard root.url.startAccessingSecurityScopedResource() else { throw AppError.fileOpenError }
                    defer { root.url.stopAccessingSecurityScopedResource() }
                    let buffer = try globalBufferManager.addBuffer(for: selectedFile.url)
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
    let bufferManager = GlobalBufferManager()
    let settings = SettingsData()
    SimpleFileBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(bufferManager)
        .environment(settings)
}
