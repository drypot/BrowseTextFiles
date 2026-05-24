//
//  BrowserView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import Combine

enum FocusTarget {
    case folderTree
    case fileList
    case textEditor
}

extension FocusedValues {
    @Entry var currentFileBrowserState: BrowserState? = nil
}

extension EnvironmentValues {
    @Entry var focusedBinding: FocusState<FocusTarget?>.Binding?
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
    @Environment(AppState.self) var appState
    @Environment(\.openWindow) private var openWindow

    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    @State private var state = BrowserState()
    @State private var window: NSWindow?
    @State private var isShowBlank = false
    @State private var cancellables = Set<AnyCancellable>()

    @FocusState private var focused: FocusTarget?

    private let initParam: BrowserInitParam

    init(_ initParam: BrowserInitParam) {
        self.initParam = initParam
        printInitParamID("init")
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
        .background(WindowReader(onResolve: handleWindow))
        .navigationTitle(state.rootName ?? "Browser")
        .environment(state)
        .environment(\.focusedBinding, $focused)
        .focusedSceneValue(\.currentFileBrowserState, state)
        .task(id: initParam) {
            processInitParam()
        }
        .sheet(
            isPresented: $state.isShowNewFileView,
            content: { NewFileSheet(state: state) }
        )
        .sheet(
            isPresented: $state.isShowRenameFolderView,
            content: { RenameFolderSheet(state: state) }
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
        .onChange(of: state.selectedFile) { _, newValue in
            guard let newValue else { return }
            saveSceneData(fileURL: newValue.url)
        }
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
                    guard state.isRootReady else { return }
                    appState.openSearchWindow(for: state, openWindow: openWindow)
                }
                .help("Search")
            }
        }
    }

    func processInitParam() {
        printInitParamID("task")
        printInitParam("task")

        // view 는 생각보다 자주 생성된다;
        // initParam nil 로도 3번 이상 생성된다;
        // 초기화 로딩 조건을 잘 설정해둬야 한다;

        // Scene 복구가 먼저다, 사용자의 마지막 파일로 돌아간다.
        if !state.isRootReady, let rootURL = loadSceneRootURL() {
            print("task: init from scene data, \(rootURL.lastPathComponent)")
            state.updateAll(fromRootURL: rootURL, fileURL: loadSceneFileURL())
            return
        }

        // initParam 으로 URL 전달받은 경우.
        if let rootURL = initParam.rootURL {
            print("task: init from initParam, \(rootURL.lastPathComponent)")
            state.updateAll(fromRootURL: rootURL, fileURL: initParam.fileURL)
            saveSceneData(rootURL: rootURL)
            appState.addRecentDocumentURL(rootURL)
            return
        }

        print("task: show blank")
        isShowBlank = true
    }

    func printInitParamID(_ part: String) {
        print("\(part): id, \(self.initParam.id.uuidString)")
    }

    func printInitParam(_ part: String) {
        print("\(part): rootURL, \(initParam.rootURL?.path ?? "nil")")
        print("\(part): fileURL, \(initParam.fileURL?.path ?? "nil")")
        print("\(part): sceneData, \(loadSceneRootURL()?.path ?? "nil")")
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

    func handleWindow(_ window: NSWindow?) {
        guard let window else { return }
        self.window = window

        // scenePhase 로는 먼가 감지가 잘 안돼서 Notification 을 쓰도록 한다.

        appState.saveBrowserWindowSize(window.frame.size)

        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification, object: window)
            .sink { _ in
                print("resign main window: \(state.debuggingName)")
                state.fileBuffer?.autoSaveTextView()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didBecomeMainNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                appState.saveBrowserWindowSize(window.frame.size)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResizeNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                appState.saveBrowserWindowSize(window.frame.size)
                //print("resize window: \(window.frame.size)")
            }
            .store(in: &cancellables)

    }
}

#Preview {
//    let appState = AppState()
//    BrowserView()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .environment(appState)
}
