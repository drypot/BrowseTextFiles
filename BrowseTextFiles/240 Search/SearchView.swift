//
//  SearchView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI
import Combine

struct SearchView: View {
    var appState: AppState
    @Bindable var state: BrowserState

    @State private var cancellables = Set<AnyCancellable>()
    @FocusState var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField("Search", text: $state.searchText)
                    .frame(minWidth: 100)
                    .focused($isFocused)
                    .task {
                        isFocused = true
                    }
                    .onSubmit {
                        state.startSearch()
                    }
                Button("Search") {
                    state.startSearch()
                }
                Button("Reset") {
                    state.clearSearchResult()
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
                                    state.locateFile(with: result.url)
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
        .navigationTitle("Search: \(state.rootName ?? "")")
        .focusedSceneValue(\.focusedBrowserState, state)
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
                state.isShowSearchWindow = false
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "search", uuid: state.id)
    }
}

#Preview {
//    SearchView()
}
