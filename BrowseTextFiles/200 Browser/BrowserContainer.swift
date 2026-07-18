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

    @State private var state = BrowserState()
    @State private var cancellables = Set<AnyCancellable>()

    init() {
        printLog("init browser container: \(state.id)")
    }

    var body: some View {
        Group {
            switch state.context.status {
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
        .navigationTitle(state.context.rootName ?? "Browser")
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbar {
            BrowserToolbar()
        }
        .modifier(BrowserSheet())
        .modifier(BrowserTask())
        .focusedSceneValue(state)
        .environment(state)
        .environment(state.context)
        .environment(state.context)
        .environment(state.context)
        .environment(state.folderListState)
        .environment(state.fileListState)
        .environment(state.searchState)
        .environment(state.historyState)
        .environment(state.editorState)
    }

    func setupWindow(_ window: NSWindow?) {
        printLog("setup browser window:")

        self.state.context.window = window

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
                // dismissWindow(id: "search", value: state.context.id)
                // dismissWindow(id: "history", value: state.context.id)
                state.releaseResource()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification, object: window)
            .sink { _ in
                consoleLog("resign main window: \(state.context.rootName ?? "nil")")
                _ = state.editorState.autoSaveFile()
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "browser", uuid: state.context.id)
    }
}

#Preview {
    BrowserContainer()
}
