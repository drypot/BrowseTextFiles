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

    var initialAction: Action?

    init(action: Action? = nil) {
        self.initialAction = action
    }

    var body: some View {
        NavigationSplitView {
            List(bufferManager.folders, children: \.folders, selection: $bufferManager.selectedFolder) { folder in
                NavigationLink(folder.name, value: folder)
            }
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
                    if let url = BookmarkManager.shared.load(forKey: "lastOpenFolder") {
                        bufferManager.setRoot(to: url)
                    }
                }
            } else {
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
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
            if case .success(let urls) = result {
                saveBookmark(urls)
                Task {
                    guard let url = urls.first else { return }
                    bufferManager.setRoot(to: url)
                }
            }
        }
        .onChange(of: bufferManager.selectedFolder) {
            bufferManager.updateFiles()
        }
        .onChange(of: bufferManager.selectedFile) {
            bufferManager.openSelectedFile()
        }
    }

    func saveBookmark(_ urls: [URL]) {
        guard let url = urls.first else { return }
        BookmarkManager.shared.save(url, forKey: "lastOpenFolder")
    }

    func loadBookmark() -> URL? {
        return BookmarkManager.shared.load(forKey: "lastOpenFolder")
    }
}

#Preview {
    let settings = SettingsData()
    TextBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
