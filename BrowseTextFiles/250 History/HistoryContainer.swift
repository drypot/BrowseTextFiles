//
//  HistoryContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import SwiftUI
import Combine

struct HistoryContainer: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var state
    @Environment(BrowserContext.self) var context
    @Environment(HistoryState.self) var historyState

    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        HistoryView()
            .background(WindowAccessor(onResolve: setupWindow))
            .navigationTitle("History: \(context.rootName ?? "")")
            .focusedSceneValue(state)
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
                historyState.isHistoryWindowPresented = false
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "history", uuid: state.context.id)
    }
}
