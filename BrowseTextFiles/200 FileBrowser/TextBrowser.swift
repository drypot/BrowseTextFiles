//
//  TextBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

struct TextBrowser: View {
    @Environment(SettingsData.self) var settings

    @State private var bufferManager = TextBufferManager()
    @State private var showImporter = false

    init(_ root: URL? = nil) {
        if let root {
            bufferManager.setRoot(to: root)
        }
    }

    var body: some View {
        NavigationSplitView {
            List(bufferManager.folders, children: \.folders, selection: $bufferManager.selectedFolder) { folder in
                NavigationLink(folder.name, value: folder)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 260, max: 520)
        } content: {
            List(bufferManager.files, id: \.self, selection: $bufferManager.selectedFile) { file in
                NavigationLink(file.lastPathComponent, value: file)
            }
        } detail: {
            if bufferManager.root == nil {
                Button("Open Folder") {
                    showImporter = true
                }
                Button("Open Last Folder") {
                    openLastOpenFolder()
                }
            } else {
                VStack {
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
                }
                .padding()
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
            if case .success(let urls) = result {
                guard let root = urls.first else { return }
                openFolder(root)
            }
        }
        .onChange(of: bufferManager.selectedFolder) {
            bufferManager.updateFiles()
        }
        .onChange(of: bufferManager.selectedFile) {
            bufferManager.openSelectedFile()
        }
    }

    func openFolder(_ root: URL) {
        let bookmark = BookmarkManager.shared
        bookmark.saveLastOpenFolder(root)
        bufferManager.setRoot(to: root)
    }

    func openLastOpenFolder() {
        let bookmark = BookmarkManager.shared
        if let root = bookmark.loadLastOpenFolder() {
            bufferManager.setRoot(to: root)
        }
    }
}

#Preview {
    let settings = SettingsData()
    TextBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
