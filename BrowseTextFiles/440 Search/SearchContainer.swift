//
//  SearchContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI
import Combine

struct SearchContainer: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        SearchView()
            .background(WindowAccessor(onResolve: setupWindow))
            .navigationTitle("Search: \(browser.context.rootName ?? "")")
            .focusedSceneValue(browser)
    }

    func setupWindow(_ window: NSWindow?) {
        printLog("setup search window:")

        guard let window else { return }

        window.collectionBehavior.insert(.ignoresCycle)
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
            .publisher(for: NSWindow.didMoveNotification, object: window)
            .sink { notification in
                saveWindowSize(window)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.willCloseNotification, object: window)
            .sink { notification in
                browser.search.isSearchWindowPresented = false
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        app.saveWindowRect(window.frame, for: "search", uuid: browser.context.id)
    }
}
