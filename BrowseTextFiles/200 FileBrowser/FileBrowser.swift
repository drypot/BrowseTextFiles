//
//  FileBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

struct FileBrowser: View {
    @Environment(SettingsData.self) var settings
    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    @State private var status = FileBrowserStatus()

    public struct InitParam: Hashable, Codable {
        let id: UUID
        let rootURL: URL?
        let fileURL: URL?

        // Codable 해야 해서 init 를 번잡스럽게 만들어 준다.
        init(id: UUID = UUID(), rootURL: URL? = nil, fileURL: URL? = nil) {
            self.id = id
            self.rootURL = rootURL
            self.fileURL = fileURL
        }
    }

    private var initParam: InitParam?

    private let log = LogStore.shared.log

    init(_ initParam: InitParam?) {
        self.initParam = initParam
    }

    var body: some View {
        VStack {
            if status.isRootReady {
                browserView
            } else {
                blankView
            }
        }
        .alert("", isPresented: $status.isShowActiveError) {
            Button("OK") { }
        } message: {
            Text(status.activeError?.message ?? "Unknown error.")
        }
        .focusedSceneValue(\.selectedBrowserStatus, status)
        .toolbarBackground(.background, for: .windowToolbar)
        .toolbarBackgroundVisibility(.automatic, for: .windowToolbar)
//        .toolbar(removing: .title)
        .toolbar {

//            ToolbarItem(placement: .navigation) {
//                ControlGroup {
//                    Button(action: {}) {
//                        Image(systemName: "chevron.left")
//                    }
//                    .help("이전 항목으로 이동")
//
//                    Button(action: {}) {
//                        Image(systemName: "chevron.right")
//                    }
//                    .help("다음 항목으로 이동")
//                }
//                .controlGroupStyle(.navigation) // macOS 스타일의 화살표 묶음으로 표시된다
//            }

            ToolbarItemGroup(placement: .navigation) {
                Button {
                    status.reloadAll()
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
                .help("Reload")
            }

            ToolbarSpacer()

            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    status.toggleSearchView()
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .help("Search")
            }
        }
        .task {
            initView()
        }
        .task {
            await autoSave()
        }
    }

    var blankView: some View {
        Button("Open Folder") {
            openFolderFromBlank()
        }
    }
    
    var browserView: some View {
        HSplitView {
//            List(status.foldersForList, children: \.folders, selection: status.selectedFolderBinding()) { folder in
//                NavigationLink(folder.name, value: folder)
//            }
//            .frame(minWidth: 180, idealWidth: 260)

            FolderTreeView(status: status)
                .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

//            List(status.fileURLsForList, id: \.self, selection: status.selectedFileBinding()) { file in
//                NavigationLink(file.lastPathComponent, value: file)
//            }
//            .frame(minWidth: 180, idealWidth: 260)

            FileListView(status: status)
                .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

            TextEditorView(status: status)
        }
        .navigationTitle(status.rootName ?? "Browser")
        .sheet(isPresented: $status.isShowNewFileView) {
            NewFileSheet(status: status)
        }
        .onChange(of: status.selectedFile) { _, newValue in
            save(sceneFileURL: newValue?.url)
        }
    }

    func initView() {
        if let rootURL = loadSceneRootURL() {
            log("restore folder: \(rootURL.lastPathComponent)")

            status.updateFolderTree(from: rootURL)
            if !status.isRootReady { return }

            if let fileURL = loadSceneFileURL() {
                status.updateAll(from: fileURL)
            } else {
                status.updateSelectedFolderToRoot()
                status.updateFileListFromSelectedFolder()
            }
            return
        }

        if let rootURL = initParam?.rootURL {
            log("open folder: \(rootURL.lastPathComponent)")

            status.updateFolderTree(from: rootURL)
            if !status.isRootReady { return }

            if let fileURL = initParam?.fileURL {
                status.updateAll(from: fileURL)
            } else {
                status.updateSelectedFolderToRoot()
                status.updateFileListFromSelectedFolder()
            }

            save(sceneRootURL: rootURL)
            settings.addRecentDocumentURL(rootURL)
            return
        }

        log("open folder: blank")
    }

    func openFolderFromBlank() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK, let rootURL = panel.url {
            log("open folder: \(rootURL.lastPathComponent)")
            status.updateFolderTree(from: rootURL)
            status.updateSelectedFolderToRoot()
            status.updateFileListFromSelectedFolder()
            save(sceneRootURL: rootURL)
            settings.addRecentDocumentURL(rootURL)
        }
    }

    func autoSave() async {
        while true {
            let seconds = UInt64(settings.autoSavePerSeconds)
            let nanoseconds: UInt64 = (seconds > 0 ? seconds : 60) * 1_000_000_000
            try? await Task.sleep(nanoseconds: nanoseconds)
            if seconds > 0 {
                status.saveFileIfEdited()
            }
        }
    }

    func save(sceneRootURL: URL) {
        sceneRootURLData = try? sceneRootURL.bookmarkData(options: .withSecurityScope)
    }

    func loadSceneRootURL() ->URL? {
        guard let data = sceneRootURLData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: data,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale)
    }

    func save(sceneFileURL url: URL?) {
        if let url {
            sceneFileURLData = try? url.bookmarkData(options: .withSecurityScope)
        }
    }

    func loadSceneFileURL() -> URL? {
        guard let data = sceneFileURLData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: data,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale)
    }
}

#Preview {
//    let settings = SettingsData()
//    FileBrowser()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .environment(settings)
}
