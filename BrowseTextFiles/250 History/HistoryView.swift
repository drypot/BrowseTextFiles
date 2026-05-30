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
    @Environment(BrowserState.self) var state

    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button("Clear") {
                    state.clearHistory()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            if !state.history.isEmpty, let rootComponents = state.rootPathComponents {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(state.history) { urlForView in
                            let path = urlForView.relativePath(from: rootComponents)
                            Button(path) {
                                state.locateFile(with: urlForView.url)
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
        .navigationTitle("History: \(state.rootName ?? "")")
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
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "history", uuid: state.id)
    }
}
