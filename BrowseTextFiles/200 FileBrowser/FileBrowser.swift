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

    @FocusState var isSearchTextFocused: Bool

    public struct InitParam: Hashable, Codable {
        let id: UUID
        let rootURL: URL?
        let fileURL: URL?

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
                Button("Open Folder") {
                    openFolderFromBlank()
                }
            }
        }
        .alert("Error", isPresented: $status.isShowActiveError) {
            Button("OK") { }
        } message: {
            Text(status.activeError?.message ?? "unknown error")
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

    var browserView: some View {
        HSplitView {
//            List(status.foldersForList, children: \.folders, selection: status.selectedFolderBinding()) { folder in
//                NavigationLink(folder.name, value: folder)
//            }
//            .frame(minWidth: 180, idealWidth: 260)

            FolderTreeView(status: status)
                .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

//            List(status.fileURLsForList, id: \.self, selection: status.selectedFileURLBinding()) { file in
//                NavigationLink(file.lastPathComponent, value: file)
//            }
//            .frame(minWidth: 180, idealWidth: 260)

            FileListView(status: status)
                .frame(minWidth: 180, idealWidth: 260, maxHeight: .infinity)

            Group {
                if status.isShowSearch {
                    searchView
                } else if let loadError = status.fileBuffer?.loadError {
                    Text(loadError)
                        .font(.custom(settings.fontName, size: settings.fontSize))
                        .lineSpacing(settings.lineSpacing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else if let buffer = status.fileBuffer {
                    @Bindable var buffer = buffer
                    TextEditor(text: $buffer.textSetter)
                        .font(.custom(settings.fontName, size: settings.fontSize))
                        .lineSpacing(settings.lineSpacing)
                } else {
                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)
        }
        .navigationTitle(status.rootName ?? "Browser")
        .sheet(isPresented: $status.isShowNewFile) {
            NewFileSheet(status: status)
        }
        .onChange(of: status.selectedFileURL) { _, newValue in
            save(sceneFileURL: newValue)
        }
    }

    var searchView: some View {
        VStack {
            HStack {
                TextField("Search", text: $status.searchText)
                    .frame(width: 320)
                    .focused($isSearchTextFocused)
                    .onSubmit {
                        status.startSearch()
                    }
                    .onExitCommand {
                        status.toggleSearchView()
                    }
                    .onAppear {
                        isSearchTextFocused = true
                    }

                Button("Search") {
                    status.startSearch()
                }

                Button("Reset") {
                    status.clearSearchResult()
                }
            }
            .padding(.bottom, 16)

            Divider()

            List {
                if let results = status.searchResults {
                    ForEach(results, id: \.url) { result in
                        Group {
                            Button(result.title) {
                                status.loadSearchedFile(from: result.url)
                            }
                            .buttonStyle(.plain)
                            .fontWeight(.bold)
                            .foregroundStyle(.link)
                            .pointerStyle(.link)

                            ForEach(result.lines, id: \.self) { line in
                                Text(line)
                            }
                            Spacer()
                                .frame(height: 8)
                        }
                    }
                    .font(.custom(settings.fontName, size: settings.fontSize))
                    .lineSpacing(settings.lineSpacing)
                    .listRowSeparator(.hidden)
                } else {
                    Text("No results")
                        .font(.custom(settings.fontName, size: settings.fontSize))
                        .lineSpacing(settings.lineSpacing)
                }
            }
        }

    }

    func initView() {
        if let rootURL = loadSceneRootURL() {
            log("restore folder: \(rootURL.lastPathComponent)")

            status.loadFolderTree(from: rootURL)
            if !status.isRootReady { return }

            if let fileURL = loadSceneFileURL() {
                status.updateSelectedFolderAndFile(with: fileURL)
            } else {
                status.updateSelectedFolderToRoot()
            }
            return
        }

        if let rootURL = initParam?.rootURL {
            log("open folder: \(rootURL.lastPathComponent)")

            status.loadFolderTree(from: rootURL)
            if !status.isRootReady { return }

            if let fileURL = initParam?.fileURL {
                status.updateSelectedFolderAndFile(with: fileURL)
            } else {
                status.updateSelectedFolderToRoot()
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
            status.loadFolderTree(from: rootURL)
            status.updateSelectedFolderToRoot()
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
