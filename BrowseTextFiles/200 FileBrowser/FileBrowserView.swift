//
//  FileBrowserView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

struct FileBrowserView: View {
    @Environment(AppState.self) var appState
    @Environment(\.openWindow) private var openWindow

    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    @State private var state = FileBrowserState()
    @State private var window: NSWindow?
    @State private var isShowBlank = false

    private var initParam: FileBrowserInitParam?

    private let log = LogStore.shared.log

    init(_ initParam: FileBrowserInitParam?) {
        self.initParam = initParam
    }

    var body: some View {
        VStack {
            if state.isRootReady {
                HSplitView {
                    // List(state.foldersForList, children: \.folders, selection: state.selectedFolderBinding()) { folder in
                    //     NavigationLink(folder.name, value: folder)
                    // }
                    // .frame(minWidth: 180, idealWidth: 260)

                    FolderTreeView()
                        .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

                    // List(state.fileURLsForList, id: \.self, selection: state.selectedFileBinding()) { file in
                    //     NavigationLink(file.lastPathComponent, value: file)
                    // }
                    // .frame(minWidth: 180, idealWidth: 260)

                    FileListView()
                        .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

                    TextBufferView()
                }
            } else if isShowBlank {
                Button("Open Folder") {
                    initViewFromOpenPanel()
                }
            } else {
                Text("Loading...")
            }
        }
        .background(WindowAccessor { window in self.window = window })
        .navigationTitle(state.rootName ?? "Browser")
        .environment(state)
        .focusedSceneValue(\.currentFileBrowserState, state)
        .task {
            initView()
        }
        .sheet(
            isPresented: $state.isShowNewFileView,
            content: { NewFileSheet(state: state) }
        )
        .sheet(
            isPresented: $state.isShowRenameFileView,
            content: { RenameFileSheet(state: state) }
        )
        .alert(
            "",
            isPresented: $state.hasAlertMessage,
            actions: { Button("OK") { } },
            message: { Text(state.alertMessage ?? "Unknown error.") }
        )
        .alert(
            "",
            isPresented: $state.hasFileBufferAlertMessage,
            actions: { Button("OK") { } },
            message: { Text(state.fileBuffer?.alertMessage ?? "Unknown error.") }
        )
        .onChange(of: state.selectedFileID) { _, newValue in
            guard let selectedFile = state.findSelectedFile() else { return }
            saveSceneData(fileURL: selectedFile.url)
        }
        // scenePhase 로는 먼가 감지가 잘 안돼서 Notification 을 쓰도록 한다.
        // .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification)) { notification in
        //     guard self.window == notification.object as? NSWindow else { return }
        //     log("noti: become main window, \(state.debuggingName)")

        // }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignMainNotification)) { notification in
            guard self.window == notification.object as? NSWindow else { return }
            log("noti: resign main window, \(state.debuggingName)")
            state.fileBuffer?.autoSaveTextView()
        }

        // 프로그램 전환할 때 ResignMain 신호가 와서 ResignActive 까지 받진 않아도 될 것 같다.
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { notification in
        //     log("noti: become active app, \(state.debuggingName)")
        // }
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { notification in
        //     log("noti: resign active app, \(state.debuggingName)")
        // }

        // 프로그램 종료할 때 ResignMain 신호가 와서 Terminate 까지 받진 않아도 될 것 같다.
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { notification in
        //     log("noti: will terminate")
        // }

        .toolbarBackground(.background, for: .windowToolbar)
        .toolbarBackgroundVisibility(.automatic, for: .windowToolbar)
        //.toolbar(removing: .title)
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
                    appState.openSearchWindow(for: state, openWindow: openWindow)
                }
                .help("Search")
            }
        }
    }

    func initView() {
        // SwiftUI가 Scene을 자동복구하는 경우. initParm 전에 이를 최우선으로 처리한다.
        if let rootURL = loadSceneRootURL() {
            state.updateAll(fromRootURL: rootURL, fileURL: loadSceneFileURL())
            return
        }
        if let rootURL = initParam?.rootURL {
            state.updateAll(fromRootURL: rootURL, fileURL: initParam?.fileURL)
            saveSceneData(rootURL: rootURL)
            appState.addRecentDocumentURL(rootURL)
            return
        }
        isShowBlank = true
    }

    private func initViewFromOpenPanel() {
        guard let window else { return }
        appState.showFolderOpenPanelFor(window) { url in
            state.updateAll(fromRootURL: url, fileURL: nil)
            saveSceneData(rootURL: url)
            appState.addRecentDocumentURL(url)
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
