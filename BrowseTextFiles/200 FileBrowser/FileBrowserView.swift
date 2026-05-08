//
//  FileBrowserView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

struct FileBrowserView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(AppState.self) var appState
    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    @State private var state = FileBrowserState()
    @State private var window: NSWindow?

    private var initParam: FileBrowserWindow.InitParam?

    private let log = LogStore.shared.log

    init(_ initParam: FileBrowserWindow.InitParam?) {
        self.initParam = initParam
    }

    var body: some View {
        VStack {
            if !state.isRootReady {
                Button("Open Folder") {
                    openFolderFromBlank()
                }
            } else {
                HSplitView {
                    // List(state.foldersForList, children: \.folders, selection: state.selectedFolderBinding()) { folder in
                    //     NavigationLink(folder.name, value: folder)
                    // }
                    // .frame(minWidth: 180, idealWidth: 260)

                    FolderTreeView(state: state)
                        .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

                    // List(state.fileURLsForList, id: \.self, selection: state.selectedFileBinding()) { file in
                    //     NavigationLink(file.lastPathComponent, value: file)
                    // }
                    // .frame(minWidth: 180, idealWidth: 260)

                    FileListView(state: state)
                        .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

                    FileBufferView(state: state)
                }
            }
        }
        .background(WindowAccessor { window in self.window = window })
        .navigationTitle(state.rootName ?? "Browser")
        .focusedSceneValue(\.currentFileBrowserState, state)
        .onChange(of: state.selectedFile) { _, newValue in
            saveSceneData(fileURL: newValue?.url)
        }
        .sheet(
            isPresented: $state.isShowNewFileView,
            content: { NewFileSheet(state: state) }
        )
        .alert(
            "",
            isPresented: $state.isShowActiveError,
            actions: { Button("OK") { } },
            message: { Text(state.activeError?.message ?? "Unknown error.") }
        )
        .task {
            initView()
        }
        // scenePhase 로는 먼가 감지가 잘 안돼서 Notification 을 쓰도록 한다.
        // .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification)) { notification in
        //     guard self.window == notification.object as? NSWindow else { return }
        //     log("notification: become main window, \(state.debuggingName)")

        // }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignMainNotification)) { notification in
            guard self.window == notification.object as? NSWindow else { return }
            log("notification: resign main window, \(state.debuggingName)")
            state.saveFileIfEdited()
        }

        // 프로그램 전환할 때 ResignMain 신호가 와서 ResignActive 까지 받진 않아도 될 것 같다.
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { notification in
        //     log("notification: become active app, \(state.debuggingName)")
        // }
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { notification in
        //     log("notification: resign active app, \(state.debuggingName)")
        // }

        // 프로그램 종료할 때 ResignMain 신호가 와서 Terminate 까지 받진 않아도 될 것 같다.
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { notification in
        //     log("notification: will terminate")
        // }

        .toolbarBackground(.background, for: .windowToolbar)
        .toolbarBackgroundVisibility(.automatic, for: .windowToolbar)
//        .toolbar(removing: .title)
        .toolbar {

            ToolbarItemGroup(placement: .navigation) {
                // Button("Prev", systemName: "chevron.left")  {
                // }
                // .help("이전 항목으로 이동")

                // Button("Next", systemName: "chevron.right") {
                // }
                // .help("다음 항목으로 이동")

                Button("Reload", systemImage: "arrow.clockwise") {
                    state.reloadAll()
                }
                .help("Reload")
            }

            ToolbarSpacer()

            ToolbarItemGroup(placement: .primaryAction) {
                Button("Search", systemImage: "magnifyingglass") {
                    appState.openSearchWindow(state: state, openWindow: openWindow)
                    // state.toggleSearchView()
                }
                .help("Search")
            }
        }
    }

    func initView() {
        if let rootURL = loadSceneRootURL() {
            log("restore folder: \(rootURL.lastPathComponent)")

            state.updateFolderTree(from: rootURL)
            if !state.isRootReady { return }

            if let fileURL = loadSceneFileURL() {
                state.updateAll(from: fileURL)
            } else {
                state.updateSelectedFolderToRoot()
                state.updateFileListFromSelectedFolder()
            }
            return
        }

        if let rootURL = initParam?.rootURL {
            log("open folder: \(rootURL.lastPathComponent)")

            state.updateFolderTree(from: rootURL)
            if !state.isRootReady { return }

            if let fileURL = initParam?.fileURL {
                state.updateAll(from: fileURL)
            } else {
                state.updateSelectedFolderToRoot()
                state.updateFileListFromSelectedFolder()
            }

            saveSceneData(rootURL: rootURL)
            appState.addRecentDocumentURL(rootURL)
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
            state.updateFolderTree(from: rootURL)
            state.updateSelectedFolderToRoot()
            state.updateFileListFromSelectedFolder()
            saveSceneData(rootURL: rootURL)
            appState.addRecentDocumentURL(rootURL)
        }
    }

    func saveSceneData(rootURL: URL) {
        sceneRootURLData = try? rootURL.bookmarkData(options: .withSecurityScope)
    }

    func loadSceneRootURL() ->URL? {
        guard let data = sceneRootURLData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: data,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale)
    }

    func saveSceneData(fileURL url: URL?) {
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
//    let appState = AppState()
//    FileBrowserView()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .environment(appState)
}
