//
//  BrowserWindowEvent.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 8/16/26.
//

import SwiftUI
import Combine

struct BrowserWindowEvent: ViewModifier {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var cancellables = Set<AnyCancellable>()

    func body(content: Content) -> some View {
        content
            .background(WindowAccessor(onResolve: setupWindow))
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
