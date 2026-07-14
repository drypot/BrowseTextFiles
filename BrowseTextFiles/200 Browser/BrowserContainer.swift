//
//  BrowserContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/11/26.
//

import SwiftUI
import Combine

struct BrowserContainer: View {
    @Environment(AppState.self) var appState

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var rootState = RootState()
    @State private var cancellables = Set<AnyCancellable>()

    init() {
        printLog("init browser container: \(rootState.id)")
    }

    var body: some View {
        Group {
            switch rootState.browserState.status {
            case .showOpenPanel:
                BrowserBlankView()
            case .loading:
                Text("Loading...")
            case .ready:
                BrowserSplitView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WindowAccessor(onResolve: setupWindow))
        .navigationTitle(rootState.browserState.rootName ?? "Browser")
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbar {
            BrowserToolbar()
        }
        .modifier(BrowserSheet())
        .modifier(BrowserTask())
        .focusedSceneValue(rootState)
        .environment(rootState)
        .environment(rootState.browserState)
        .environment(rootState.browserState)
        .environment(rootState.browserState)
        .environment(rootState.folderListState)
        .environment(rootState.fileListState)
        .environment(rootState.searchState)
        .environment(rootState.historyState)
        .environment(rootState.editorState)
    }

    func setupWindow(_ window: NSWindow?) {
        printLog("setup browser window:")

        self.rootState.browserState.window = window

        guard let window else { return }

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
                // dismissWindow(id: "search", value: rootState.browserState.id)
                // dismissWindow(id: "history", value: rootState.browserState.id)
                rootState.releaseResource()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification, object: window)
            .sink { _ in
                consoleLog("resign main window: \(rootState.browserState.rootName ?? "nil")")
                _ = rootState.editorState.autoSaveFile()
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "browser", uuid: rootState.browserState.id)
    }
}

#Preview {
    BrowserContainer()
}
