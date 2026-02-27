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

    @State private var fileBufferManager = FileBufferManager()
    @State private var selectedBuffer: FileBuffer?

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
                    ForEach(fileBufferManager.buffers) { buffer in
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
        if let selectedFileURL = selectedFile?.url,
           let rootURL = folderListManager.root?.url,
           let buffer = try? fileBufferManager.addBuffer(for: selectedFileURL, root: rootURL) {
            selectedBuffer = buffer
        } else {
            print("Can't read file contents")
        }
    }
}

#Preview {
    let settings = SettingsData()
    SimpleFileBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
