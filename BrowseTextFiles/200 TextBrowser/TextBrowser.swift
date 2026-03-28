//
//  TextBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

struct TextBrowser: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(SettingsData.self) var settings

    @SceneStorage("rootURLData") private var rootURLData: Data?

    @State private var bufferManager = TextBufferManager()

    private var initRoot: URL?

    init(_ root: URL? = nil) {
        initRoot = root
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
                    openFolder()
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
                    //.tabViewCustomization(<#T##customization: Binding<TabViewCustomization>?##Binding<TabViewCustomization>?#>)
                }
                .padding()
            }
        }
        .onChange(of: bufferManager.selectedFolder) {
            bufferManager.updateFiles()
        }
        .onChange(of: bufferManager.selectedFile) {
            bufferManager.openSelectedFile()
        }
        .task {
            if let root = initRoot {
                saveRootURLAndOpenFolder(root)
            } else {
                if let root = loadRootURL() {
                    saveRootURLAndOpenFolder(root)
                }
            }
        }
    }

    func openFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            if let url = panel.url {
                saveRootURLAndOpenFolder(url)
            }
        }
    }

    func saveRootURLAndOpenFolder(_ root: URL) {
        saveRootURL(root)
        openFolder(root)
    }

    func openFolder(_ root: URL) {
        bufferManager.setRoot(to: root)
    }

//    func openLastOpenFolder() {
//        let bookmark = BookmarkManager.shared
//        if let root = bookmark.loadLastOpenFolder() {
//            bufferManager.setRoot(to: root)
//        }
//    }

    func saveRootURL(_ url: URL) {
        do {
            let securityScoped = url.startAccessingSecurityScopedResource()
            defer { if securityScoped { url.stopAccessingSecurityScopedResource() } }
            rootURLData = try url.bookmarkData(options: .withSecurityScope,
                                               includingResourceValuesForKeys: nil,
                                               relativeTo: nil)
        } catch {
            print("saving bookmark failed: \(error)")
        }
    }

    func loadRootURL() -> URL? {
        do {
            guard let data = rootURLData else { return nil }
            var isStale = false
            let url = try URL(resolvingBookmarkData: data,
                              options: .withSecurityScope,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            if isStale {
                saveRootURL(url)
            }
            return url
        } catch {
            print("loading bookmark failed: \(error)")
        }
        return nil
    }
}

#Preview {
    let settings = SettingsData()
    TextBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
