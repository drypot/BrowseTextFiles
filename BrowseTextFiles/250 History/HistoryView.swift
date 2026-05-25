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
                    //
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            if let results = state.searchResults, !results.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(results) { result in
                            VStack(alignment: .leading) {
                                Button(result.title) {
                                    state.updateAll(fromFileURL: result.url)
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.link)
                                .pointerStyle(.link)

                                VStack(alignment: .leading) {
                                    ForEach(result.lines) { line in
                                        Text(line.text)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                }
            } else {
                Text("No results")
                    .padding()
                Spacer()
            }
        }
        .background(WindowReader(onResolve: setupWindow))
        .navigationTitle("History: \(state.rootName ?? "")")
        .frame(minWidth: 440)
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
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveHistoryWindowSize(window.frame.size)
    }
}
