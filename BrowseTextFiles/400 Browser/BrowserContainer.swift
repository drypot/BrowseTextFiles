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
        logger.info("init browser container:")
    }

    var body: some View {
        Group {
            switch browser.context.status {
            case .showOpenPanel:
                BrowserBlank()
            case .loading:
                Text("Loading...")
            case .ready:
                BrowserNavigator()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WindowAccessor(onResolve: setupWindow))
        .windowToolbarFullScreenVisibility(.onHover)
        .toolbarBackground(.hidden, for: .windowToolbar)
        //.navigationTitle(browser.context.rootName ?? "Browser")
        .toolbar(removing: .title)
        .toolbar {
            BrowserToolbar()
        }
        .modifier(BrowserSheet())
        .modifier(BrowserInit())
        .focusedSceneValue(browser)
        .environment(browser)
        .environment(browser.context)
        .environment(browser.folderList)
        .environment(browser.fileList)
        .environment(browser.search)
        .environment(browser.history)
        .environment(browser.text)
    }

    func setupWindow(_ window: NSWindow?) {
        logger.info("setup browser window:")

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
                logger.info("resign main window: \(browser.context.rootName ?? "nil")")
                _ = browser.text.autoSaveFile()
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
