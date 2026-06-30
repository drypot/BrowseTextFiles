//
//  BrowserView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import Combine

enum FocusedView {
    case folderTree
    case fileList
    case textEditor
}

extension FocusedValues {
    @Entry var focusedBrowserState: BrowserState?
}

extension EnvironmentValues {
    @Entry var focusedViewBinding: FocusState<FocusedView?>.Binding?
}

struct BrowserInitParam: Hashable, Codable {
    // 동일 폴더를 두 창에서 열려면 id 로 구분해야 한다.
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

struct BrowserView: View {
    var appState: AppState
    var initParam: BrowserInitParam

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    @State private var state = BrowserState()
    @State private var window: NSWindow?
    @State private var isShowBlank = false
    @State private var cancellables = Set<AnyCancellable>()

    @FocusState private var focusedView: FocusedView?

    var body: some View {
        VStack {
            if state.isRootReady {
                NavigationSplitView {
                    FolderTreeView(appState: appState, state: state)
                        .frame(minWidth: 200, maxHeight: .infinity)
                } content: {
                    FileListView(appState: appState, state: state)
                        .frame(minWidth: 180, maxHeight: .infinity)
                } detail: {
                    TextBufferView(appState: appState, state: state)
                        .frame(minWidth: 300, maxHeight: .infinity)
                        //.layoutPriority(1)
                }

//                HSplitView {
//                    FolderTreeView()
//                        .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)
//
//                    FileListView()
//                        .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)
//
//                    TextBufferView()
//                }
            } else if isShowBlank {
                Button("Open Folder") {
                    showOpenPanel()
                }
            } else {
                Text("Loading...")
            }
        }
        .background(WindowReader(onResolve: setupWindow))
        .navigationTitle(state.rootName ?? "Browser")
        .environment(state)
        .environment(\.focusedViewBinding, $focusedView)
        .focusedSceneValue(\.focusedBrowserState, state)
        .task(id: initParam) {
            initView()
        }
        .sheet(
            isPresented: $state.isShowNewFileSheet,
            content: { NewFileSheet(appState: appState, state: state) }
        )
        .sheet(
            isPresented: $state.isShowRenameSheet,
            content: { RenameSheet(appState: appState, state: state) }
        )
        .alert(
            "",
            isPresented: $state.hasAlertMessage,
            actions: { Button("OK") { } },
            message: { Text(state.alertMessage) }
        )
        .alert(
            "",
            isPresented: $state.hasFileBufferAlertMessage,
            actions: { Button("OK") { } },
            message: { Text(state.textBuffer?.alertMessage ?? "nil") }
        )
        .onChange(of: state.selectedFile) { _, newValue in
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
        //         dismissWindow(id: "search", value: state.id)
        //         dismissWindow(id: "history", value: state.id)
        //         state.releaseResource()
        //     }
        // }
        // .task(id: window) {
        //     guard let window else { return }
        //     let sequence = NotificationCenter.default.notifications(named: NSWindow.didResignMainNotification, object: window)
        //     for await _ in sequence {
        //         print("resign main window: \(state.rootName ?? "nil")")
        //         state.textBuffer?.autoSaveTextView()
        //     }
        // }
    }

    func printInitParamID(_ part: String) {
        print("\(part): id, \(self.initParam.id.uuidString)")
    }

    func printInitParam(_ part: String) {
        print("\(part): rootURL, \(initParam.rootURL?.path ?? "nil")")
        print("\(part): fileURL, \(initParam.fileURL?.path ?? "nil")")
        print("\(part): sceneData, \(loadRootURL()?.path ?? "nil")")
    }

    func initView() {
        //printInitParamID("task")
        //printInitParam("task")

        // view 는 생각보다 자주 생성된다;
        // initParam nil 로도 3번 이상 생성된다;
        // 초기화 로딩 조건을 잘 설정해둬야 한다;

        // Scene 복구가 먼저다, 사용자의 마지막 파일로 돌아간다.
        if !state.isRootReady, let rootURL = loadRootURL() {
            state.initState(with: rootURL, fileURL: loadFileURL())
            return
        }

        // initParam 으로 URL 전달받은 경우.
        if let rootURL = initParam.rootURL {
            state.initState(with: rootURL, fileURL: initParam.fileURL)
            saveRootURL(rootURL)
            appState.addRecentDocumentURL(rootURL)
            return
        }

        isShowBlank = true
    }

    private func showOpenPanel() {
        guard let window else { return }
        appState.showFolderOpenPanelFor(window) { url in
            state.initState(with: url, fileURL: nil)
            saveRootURL(url)
            appState.addRecentDocumentURL(url)
        }
    }

    func saveRootURL(_ rootURL: URL) {
        sceneRootURLData = try? rootURL.bookmarkData(options: .withSecurityScope)
    }

    func loadRootURL() ->URL? {
        guard let data = sceneRootURLData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: data,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale)
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
                print("333")
                dismissWindow(id: "search", value: state.id)
                dismissWindow(id: "history", value: state.id)
                state.releaseResource()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification, object: window)
            .sink { _ in
                print("resign main window: \(state.rootName ?? "nil")")
                state.textBuffer?.autoSaveTextView()
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "browser", uuid: state.id)
    }
}
