//
//  BrowserView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import Combine

struct BrowserView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @Environment(AppState.self) var appState

    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    @State private var browserState = BrowserState()
    @State private var window: NSWindow?
    @State private var isShowBlank = false
    @State private var cancellables = Set<AnyCancellable>()

    init() {
        // 여기서 log 쓰면 무한 루프.
        printLog("init BrowserView: \(browserState.id)")
    }

    var body: some View {
        //Text("browserState.id: \(browserState.id)")
        VStack {
            if browserState.isRootReady {
                NavigationSplitView {
                    FolderTreeView()
                        .frame(minWidth: 200, maxHeight: .infinity)
                } content: {
                    FileListView()
                        .frame(minWidth: 180, maxHeight: .infinity)
                } detail: {
                    EditorView()
                        .frame(minWidth: 300, maxHeight: .infinity)
                        //.layoutPriority(1)
                }
            } else if isShowBlank {
                Button("Open Folder") {
                    showOpenPanel()
                }
            } else {
                Text("Loading...")
            }
        }
        .navigationTitle(browserState.rootName ?? "Browser")
        .background(WindowAccessor(onResolve: setupWindow))
        .task {
            // 아직 SceneStorage 가 업데이트 안 되어 있다;
            // Task.yield() 로 한템포 쉬어준다;
            await Task.yield()

            initView()
        }
        .sheet(
            isPresented: $browserState.isShowNewFileSheet,
            content: { NewFileSheet() }
        )
        .sheet(
            isPresented: $browserState.renameState.isRenameSheetPresented,
            content: { RenameSheet() }
        )
        .alert(
            "",
            isPresented: $browserState.alertState.hasMessage,
            actions: { Button("OK") { } },
            message: { Text(browserState.alertState.message) }
        )
        .onChange(of: browserState.fileListState.selectedFileIDs) { _, ids in
            guard ids.count == 1 else { return }
            guard let first = ids.first else { return }
            saveFileURL(first)
        }
        // .environment(browserState) 가 NewFileSheet 아래/바깥쪽에 있어야 NewFileSheet 에서 사용할 수 있다.
        .environment(browserState)
        .environment(browserState.alertState)
        .environment(browserState.newFileState)
        .environment(browserState.renameState)
        .environment(browserState.fileListState)
        .environment(browserState.searchState)
        .environment(browserState.historyState)
        .environment(browserState.editorState)
        .focusedSceneValue(browserState)
    }

    func initView() {
        // Scene 복구가 먼저다, 사용자의 마지막 파일로 돌아간다.
        if let rootURL = loadRootURL() {
            browserState.initState(with: rootURL, fileURL: loadFileURL())
            return
        }

        // initParam 으로 URL 전달받은 경우.
        if let rootURL = appState.newWindowRootURL {
            browserState.initState(with: rootURL, fileURL: appState.newWindowFileURL)
            appState.newWindowRootURL = nil
            appState.newWindowFileURL = nil
            saveRootURL(rootURL)
            appState.addRecentDocumentURL(rootURL)
            return
        }

        isShowBlank = true
    }

    private func showOpenPanel() {
        guard let window else { return }
        appState.showFolderOpenPanelFor(window) { url in
            browserState.initState(with: url, fileURL: nil)
            saveRootURL(url)
            appState.addRecentDocumentURL(url)
        }
    }

    func saveRootURL(_ rootURL: URL) {
        consoleLog("save scene RootURL: \(browserState.id)")
        sceneRootURLData = try? rootURL.bookmarkData(options: .withSecurityScope)
    }

    func loadRootURL() ->URL? {
        guard let data = sceneRootURLData else { return nil }
        var isStale = false
        let url = try? URL(resolvingBookmarkData: data,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale)
        consoleLog("load scene RootURL: \(url?.path(percentEncoded: false) ?? "nil")")
        return url
    }

    func saveFileURL(_ url: URL?) {
        if let url {
            sceneFileURLData = try? url.bookmarkData(options: .withSecurityScope)
        }
    }

    func loadFileURL() -> URL? {
        guard let data = sceneFileURLData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: data,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale)
    }

    func setupWindow(_ window: NSWindow?) {
        guard let window else { return }
        self.window = window

        saveWindowSize(window)

        NotificationCenter.default
            .publisher(for: NSWindow.didBecomeMainNotification, object: window)
            .sink { notification in
                saveWindowSize(window)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResizeNotification, object: window)
            .sink { notification in
                saveWindowSize(window)
            }
            .store(in: &cancellables)

         NotificationCenter.default
            .publisher(for: NSWindow.willCloseNotification, object: window)
            .sink { notification in
                dismissWindow(id: "search", value: browserState.id)
                dismissWindow(id: "history", value: browserState.id)
                browserState.releaseResource()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification, object: window)
            .sink { _ in
                consoleLog("resign main window: \(browserState.rootName ?? "nil")")
                _ = browserState.editorState.autoSaveFile()
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "browser", uuid: browserState.id)
    }
}
