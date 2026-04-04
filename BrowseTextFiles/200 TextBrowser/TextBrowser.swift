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
        VStack {
            if bufferManager.root == nil {
                Button("Open Folder") {
                    openFolder()
                }
            } else {
                HSplitView {
                    List(bufferManager.folders, children: \.folders, selection: $bufferManager.selectedFolder) { folder in
                        NavigationLink(folder.name, value: folder)
                    }
                    .frame(minWidth: 180, idealWidth: 260)

                    List(bufferManager.files, id: \.self, selection: $bufferManager.selectedFile) { file in
                        NavigationLink(file.lastPathComponent, value: file)
                    }
                    .frame(minWidth: 180, idealWidth: 260)

                    VStack {
                        if bufferManager.root == nil {
                            Button("Open Folder") {
                                openFolder()
                            }
                        } else {
                            if let buffer = bufferManager.buffer {
                                @Bindable var buffer = buffer
                                TextEditor(text: $buffer.text)
                                    .font(.custom(settings.fontName, size: settings.fontSize))
                                    .lineSpacing(settings.lineSpacing)
                                    .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                            } else {
                                Spacer()
                            }
                        }
                    }
                    .frame(minWidth: 300, maxWidth: .infinity)
                    .layoutPriority(1)
                }
            }
        }
        .toolbarBackground(.background, for: .windowToolbar)
        .toolbarBackgroundVisibility(.automatic, for: .windowToolbar)
        .toolbar(removing: .title)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                ControlGroup {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                    }
                    .help("이전 항목으로 이동")

                    Button(action: {}) {
                        Image(systemName: "chevron.right")
                    }
                    .help("다음 항목으로 이동")
                }
                .controlGroupStyle(.navigation) // macOS 스타일의 화살표 묶음으로 표시된다
            }
        }
        .onChange(of: bufferManager.selectedFolder) {
            bufferManager.updateFiles()
        }
        .onChange(of: bufferManager.selectedFile) {
            bufferManager.openSelectedFile()
        }
        .onOpenURL { url in
            print("onOpenURL: \(url.path)")
            // 여기서 파일을 로드하는 로직을 구현한다.
        }
        .task {
            if let root = initRoot {
                openFolderAndSaveURL(root)
            } else {
                if let root = loadRootURL() {
                    openFolder(root)
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
                openFolderAndSaveURL(url)
            }
        }
    }

    func openFolder(_ root: URL) {
        bufferManager.setRoot(to: root)
    }

    func openFolderAndSaveURL(_ root: URL) {
        openFolder(root)
        if bufferManager.root != nil {
            saveRootURL(root)
            settings.addRecentDocumentURL(root)
        }
    }

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
