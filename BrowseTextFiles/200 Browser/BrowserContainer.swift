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

    @State private var stateRoot = BrowserStateRoot()
    @State private var cancellables = Set<AnyCancellable>()

    init() {
        printLog("init browser container: \(stateRoot.id)")
    }

    var body: some View {
        Group {
            switch stateRoot.browserState.status {
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
        .navigationTitle(stateRoot.browserState.rootName ?? "Browser")
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbar {
            BrowserToolbar()
        }
        .modifier(BrowserSheet())
        .modifier(BrowserTask())
        .focusedSceneValue(stateRoot)
        .environment(stateRoot)
        .environment(stateRoot.browserState)
        .environment(stateRoot.browserState)
        .environment(stateRoot.browserState)
        .environment(stateRoot.folderListState)
        .environment(stateRoot.fileListState)
        .environment(stateRoot.searchState)
        .environment(stateRoot.historyState)
        .environment(stateRoot.editorState)
    }

    func setupWindow(_ window: NSWindow?) {
        printLog("setup browser window:")

        self.stateRoot.browserState.window = window

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
                // dismissWindow(id: "search", value: stateRoot.browserState.id)
                // dismissWindow(id: "history", value: stateRoot.browserState.id)
                stateRoot.releaseResource()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification, object: window)
            .sink { _ in
                consoleLog("resign main window: \(stateRoot.browserState.rootName ?? "nil")")
                _ = stateRoot.editorState.autoSaveFile()
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "browser", uuid: stateRoot.browserState.id)
    }
}

#Preview {
    BrowserContainer()
}
