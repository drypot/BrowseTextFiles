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
    // @Environment(\.scenePhase) private var scenePhase
    @Environment(SettingsData.self) var settings
    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    @State private var status = FileBrowserStatus()
    @State private var window: NSWindow?

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
            if !status.isRootReady {
                Button("Open Folder") {
                    openFolderFromBlank()
                }
            } else {
                HSplitView {
                    // List(status.foldersForList, children: \.folders, selection: status.selectedFolderBinding()) { folder in
                    //     NavigationLink(folder.name, value: folder)
                    // }
                    // .frame(minWidth: 180, idealWidth: 260)

                    FolderTreeView(status: status)
                        .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

                    // List(status.fileURLsForList, id: \.self, selection: status.selectedFileBinding()) { file in
                    //     NavigationLink(file.lastPathComponent, value: file)
                    // }
                    // .frame(minWidth: 180, idealWidth: 260)

                    FileListView(status: status)
                        .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

                    FileBufferView(status: status)
                }
            }
        }
        .background(WindowAccessor { window in self.window = window })
        .navigationTitle(status.rootName ?? "Browser")
        .focusedSceneValue(\.selectedBrowserStatus, status)
        .onChange(of: status.selectedFile) { _, newValue in
            saveSceneData(fileURL: newValue?.url)
        }
        .sheet(
            isPresented: $status.isShowNewFileView,
            content: { NewFileSheet(status: status) }
        )
        .alert(
            "",
            isPresented: $status.isShowActiveError,
            actions: { Button("OK") { } },
            message: { Text(status.activeError?.message ?? "Unknown error.") }
        )
        .task {
            initView()
        }
        // scenePhase 로는 먼가 감지가 잘 안돼서 Notification 을 쓰도록 한다.
        // .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification)) { notification in
        //     guard self.window == notification.object as? NSWindow else { return }
        //     log("notification: become main window, \(status.debuggingName)")
        //     status.saveFileIfEdited()
        // }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignMainNotification)) { notification in
            guard self.window == notification.object as? NSWindow else { return }
            log("notification: resign main window, \(status.debuggingName)")
            status.saveFileIfEdited()
        }

        // 프로그램 전환할 때 ResignMain 신호가 와서 ResignActive 까지 받진 않아도 될 것 같다.
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { notification in
        //     log("notification: become active app, \(status.debuggingName)")
        //     status.saveFileIfEdited()
        // }
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { notification in
        //     log("notification: resign active app, \(status.debuggingName)")
        //     status.saveFileIfEdited()
        // }

        // 프로그램 종료할 때 ResignMain 신호가 와서 Terminate 까지 받진 않아도 될 것 같다.
        // .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { notification in
        //     log("notification: will terminate")
        //     status.saveFileIfEdited()
        // }

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
                    openWindow(id: "search", value: status.id)
                    // status.toggleSearchView()
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .help("Search")
            }
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

            saveSceneData(rootURL: rootURL)
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
            saveSceneData(rootURL: rootURL)
            settings.addRecentDocumentURL(rootURL)
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
//    let settings = SettingsData()
//    FileBrowserView()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .environment(settings)
}
