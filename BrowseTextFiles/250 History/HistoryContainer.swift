//
//  HistoryContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import SwiftUI
import Combine

struct HistoryContainer: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        HistoryView()
            .background(WindowAccessor(onResolve: setupWindow))
            .navigationTitle("History: \(browser.context.rootName ?? "")")
            .focusedSceneValue(browser)
    }
    
    func setupWindow(_ window: NSWindow?) {
        printLog("setup history window:")

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
                browser.history.isHistoryWindowPresented = false
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        app.saveWindowRect(window.frame, for: "history", uuid: browser.context.id)
    }
}
