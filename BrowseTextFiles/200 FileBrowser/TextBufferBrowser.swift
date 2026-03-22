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

    @State private var bufferManager = TextBufferManager()

    var initialAction: Action?

    init(action: Action? = nil) {
        self.initialAction = action
    }

    var body: some View {
        if let root = bufferManager.root {
            NavigationSplitView {
                List(bufferManager.folders, children: \.folders, selection: $bufferManager.selectedFolder) { folder in
                    NavigationLink(folder.name, value: folder)
                }
                .navigationTitle(root.name)
            } content: {
                List(bufferManager.files, id: \.self, selection: $bufferManager.selectedFile) { file in
                    NavigationLink(file.lastPathComponent, value: file)
                }
            } detail: {
                TabView(selection: $bufferManager.selectedBuffer) {
                    ForEach(bufferManager.buffers) { buffer in
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
            .onChange(of: bufferManager.selectedFolder) {
                bufferManager.updateFiles()
            }
            .onChange(of: bufferManager.selectedFile) {
                bufferManager.openSelectedFile()
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
        bufferManager.setRoot(to: url)
    }

    func openLastFolder() {
        if let url = BookmarkManager.shared.load(forKey: "lastOpenFolder") {
            openFolder(from: url)
        }
    }
}

#Preview {
    let settings = SettingsData()
    TextBufferBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
