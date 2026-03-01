//
//  TextBufferBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

struct TextBufferBrowser: View {
    @Environment(SettingsData.self) var settings

    @State private var folderListManager = FolderListManager()
    @State private var selectedFolder: Folder?

    @State private var fileListManager = FileListManager()
    @State private var selectedFile: URL?

    @State private var textBufferManager = TextBufferManager()
    @State private var selectedTextBuffer: TextBuffer?

    var body: some View {
        if let root = folderListManager.root {
            NavigationSplitView {
                List(folderListManager.folders, children: \.folders, selection: $selectedFolder) { folder in
                    NavigationLink(folder.name, value: folder)
                }
                .navigationTitle(root.name)
            } content: {
                List(fileListManager.files, id: \.self, selection: $selectedFile) { file in
                    NavigationLink(file.lastPathComponent, value: file)
                }
            } detail: {
                TabView(selection: $selectedTextBuffer) {
                    ForEach(textBufferManager.files) { buffer in
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
        guard let selectedFolderURL = selectedFolder?.url else { return }
        guard let rootURL = folderListManager.root?.url else { return }

        do {
            guard rootURL.startAccessingSecurityScopedResource() else { return }
            defer { rootURL.stopAccessingSecurityScopedResource() }
            try fileListManager.update(from: selectedFolderURL)
            selectedFile = nil
        } catch {
            print("file list update failed: \(error.localizedDescription)")
        }
    }

    func openFile() {
        do {
            guard let selectedFileURL = selectedFile else { return }
            guard let rootURL = folderListManager.root?.url else { return }
            if let file = textBufferManager.file(for: selectedFileURL) {
                selectedTextBuffer = file
            } else {
                guard rootURL.startAccessingSecurityScopedResource() else { return }
                defer { rootURL.stopAccessingSecurityScopedResource() }
                selectedTextBuffer = try textBufferManager.addFile(from: selectedFileURL)
            }
        } catch {
            print("file open failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let settings = SettingsData()
    TextBufferBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
