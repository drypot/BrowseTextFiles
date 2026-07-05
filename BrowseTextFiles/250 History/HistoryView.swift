//
//  HistoryView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import SwiftUI
import Combine

struct HistoryView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var browserState
    @Environment(HistoryState.self) var historyState

    @State private var cancellables = Set<AnyCancellable>()

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
        .background(WindowAccessor(onResolve: setupWindow))
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
        appState.saveWindowRect(window.frame, for: "history", uuid: browserState.id)
    }
}
