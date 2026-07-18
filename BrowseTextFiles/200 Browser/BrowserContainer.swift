//
//  BrowserContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/11/26.
//

import SwiftUI
import Combine

struct BrowserContainer: View {
    @Environment(AppState.self) var app

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var browser = BrowserState()
    @State private var cancellables = Set<AnyCancellable>()

    init() {
        printLog("init browser container: \(browser.id)")
    }

    var body: some View {
        Group {
            switch browser.context.status {
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
        .navigationTitle(browser.context.rootName ?? "Browser")
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbar {
            BrowserToolbar()
        }
        .modifier(BrowserSheet())
        .modifier(BrowserTask())
        .focusedSceneValue(browser)
        .environment(browser)
        .environment(browser.context)
        .environment(browser.folderList)
        .environment(browser.fileList)
        .environment(browser.search)
        .environment(browser.history)
        .environment(browser.editor)
    }

    func setupWindow(_ window: NSWindow?) {
        printLog("setup browser window:")

        self.browser.context.window = window

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
                // dismissWindow(id: "search", value: browser.context.id)
                // dismissWindow(id: "history", value: browser.context.id)
                browser.releaseResource()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResignMainNotification, object: window)
            .sink { _ in
                consoleLog("resign main window: \(browser.context.rootName ?? "nil")")
                _ = browser.editor.autoSaveFile()
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        app.saveWindowRect(window.frame, for: "browser", uuid: browser.context.id)
    }
}

#Preview {
    BrowserContainer()
}
