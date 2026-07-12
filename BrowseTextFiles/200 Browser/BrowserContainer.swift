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

    @State private var browserState = BrowserState()
    @State private var cancellables = Set<AnyCancellable>()

    init() {
        printLog("init browser container: \(browserState.id)")
    }

    var body: some View {
        Group {
            switch browserState.status {
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
        .navigationTitle(browserState.rootState.rootName ?? "Browser")
        .toolbar {
            BrowserToolbar()
        }
        .modifier(BrowserSheet())
        .modifier(BrowserTask())
        .focusedSceneValue(browserState)
        .environment(browserState)
        .environment(browserState.rootState)
        .environment(browserState.targetState)
        .environment(browserState.alertState)
        .environment(browserState.newFileState)
        .environment(browserState.renameState)
        .environment(browserState.folderTreeState)
        .environment(browserState.fileListState)
        .environment(browserState.searchState)
        .environment(browserState.historyState)
        .environment(browserState.editorState)
    }

    func setupWindow(_ window: NSWindow?) {
        printLog("setup browser window:")

        self.browserState.window = window

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
                dismissWindow(id: "search", value: browserState.id)
                dismissWindow(id: "history", value: browserState.id)
                browserState.releaseResource()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification, object: window)
            .sink { _ in
                consoleLog("resign main window: \(browserState.rootState.rootName ?? "nil")")
                _ = browserState.editorState.autoSaveFile()
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "browser", uuid: browserState.id)
    }
}

#Preview {
    BrowserContainer()
}
