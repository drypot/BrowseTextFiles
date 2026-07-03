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

    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    @State private var browserState = BrowserState()
    @State private var window: NSWindow?
    @State private var isShowBlank = false
    @State private var cancellables = Set<AnyCancellable>()

    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
        print("init BrowserView: \(browserState.id)")
    }

    var body: some View {
        Text("browserState.id: \(browserState.id)")
        VStack {
            if browserState.isRootReady {
                NavigationSplitView {
                    FolderTreeView(appState: appState, browserState: browserState)
                        .frame(minWidth: 200, maxHeight: .infinity)
                } content: {
                    FileListView(appState: appState, browserState: browserState)
                        .frame(minWidth: 180, maxHeight: .infinity)
                } detail: {
                    EditorView(appState: appState, browserState: browserState)
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
        .background(WindowReader(onResolve: setupWindow))
        .navigationTitle(browserState.rootName ?? "Browser")
        .focusedSceneValue(browserState)
        .task {
            initView()
        }
        .sheet(
            isPresented: $browserState.isShowNewFileSheet,
            content: { NewFileSheet(appState: appState, browserState: browserState) }
        )
        .sheet(
            isPresented: $browserState.isShowRenameSheet,
            content: { RenameSheet(appState: appState, browserState: browserState) }
        )
        .alert(
            "",
            isPresented: $browserState.alertState.hasMessage,
            actions: { Button("OK") { } },
            message: { Text(browserState.alertState.message) }
        )
        .onChange(of: browserState.fileListState.selectedFile) { _, newValue in
            guard let newValue else { return }
            saveFileURL(newValue.url)
        }
        //.toolbar(removing: .title)

        // 다른 것은 잘 작동하는데, willCloseNotification 을 받지 못한다;
        // 걍 원래 쓰던 Combine 코드 계속 쓰는 것으로;
        //
        // .task(id: window) {
        //     guard let window else { return }
        //     let sequence = NotificationCenter.default.notifications(named: NSWindow.didBecomeMainNotification, object: window)
        //     for await _ in sequence {
        //         saveWindowSize(window)
        //     }
        // }
        // .task(id: window) {
        //     guard let window else { return }
        //     let sequence = NotificationCenter.default.notifications(named: NSWindow.didResizeNotification, object: window)
        //     for await _ in sequence {
        //         saveWindowSize(window)
        //     }
        // }
        // .task(id: window) {
        //     guard let window else { return }
        //     let sequence = NotificationCenter.default.notifications(named: NSWindow.willCloseNotification, object: window)
        //     for await _ in sequence {
        //         dismissWindow(id: "search", value: browserState.id)
        //         dismissWindow(id: "history", value: browserState.id)
        //         browserState.releaseResource()
        //     }
        // }
        // .task(id: window) {
        //     guard let window else { return }
        //     let sequence = NotificationCenter.default.notifications(named: NSWindow.didResignMainNotification, object: window)
        //     for await _ in sequence {
        //         print("resign main window: \(browserState.rootName ?? "nil")")
        //         browserState.textBuffer?.autoSaveFile()
        //     }
        // }
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
        print("save RootURL: \(browserState.id)")
        sceneRootURLData = try? rootURL.bookmarkData(options: .withSecurityScope)
    }

    func loadRootURL() ->URL? {
        print("load RootURL: \(browserState.id)")
        guard let data = sceneRootURLData else { return nil }
        var isStale = false
        let url = try? URL(resolvingBookmarkData: data,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale)
        print("load RootURL: \(url?.lastPathComponent ?? "nil")")
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
                guard let window = notification.object as? NSWindow else { return }
                saveWindowSize(window)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResizeNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
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
                print("resign main window: \(browserState.rootName ?? "nil")")
                _ = browserState.editorState.autoSaveFile()
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "browser", uuid: browserState.id)
    }
}
