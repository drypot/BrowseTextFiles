//
//  HistoryView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import SwiftUI
import Combine

struct HistoryView: View {
    var appState: AppState
    var browserState: BrowserState
    var historyState: HistoryState

    @State private var cancellables = Set<AnyCancellable>()

    init(browserState: BrowserState) {
        self.appState = browserState.appState
        self.browserState = browserState
        self.historyState = browserState.historyState
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button("Clear") {
                    historyState.clearHistory()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            if !historyState.history.isEmpty, let rootComponents = browserState.rootPathComponents {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(historyState.history) { historyItem in
                            let path = historyItem.relativePath(from: rootComponents)
                            Button(path) {
                                browserState.locateFile(with: historyItem.url)
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.link)
                        .pointerStyle(.link)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                }
            } else {
                Spacer()
            }
        }
        .background(WindowReader(onResolve: setupWindow))
        .navigationTitle("History: \(browserState.rootName ?? "")")
        .focusedSceneValue(browserState)
    }
    
    func setupWindow(_ window: NSWindow?) {
        guard let window else { return }

        window.collectionBehavior.insert(.ignoresCycle)
        saveWindowSize(window)

        NotificationCenter.default
            .publisher(for: NSWindow.didBecomeMainNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                saveWindowSize(window)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResizeNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                saveWindowSize(window)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didMoveNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                saveWindowSize(window)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.willCloseNotification, object: window)
            .sink { notification in
                historyState.isHistoryWindowShown = false
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "history", uuid: browserState.id)
    }
}
