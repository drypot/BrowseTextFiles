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
    var browserState: BrowserState
    @Bindable var searchState: SearchState

    @State private var cancellables = Set<AnyCancellable>()
    @FocusState var isFocused: Bool

    init(appState: AppState, browserState: BrowserState) {
        self.appState = appState
        self.browserState = browserState
        self.searchState = browserState.searchState
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField("Search", text: $searchState.searchText)
                    .frame(minWidth: 100)
                    .focused($isFocused)
                    .task {
                        isFocused = true
                    }
                    .onSubmit {
                        startSearch()
                    }
                Button("Search") {
                    startSearch()
                }
                Button("Reset") {
                    searchState.clearSearchResult()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            if let results = searchState.searchResults, !results.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(results) { result in
                            VStack(alignment: .leading) {
                                Button(result.title) {
                                    browserState.locateFile(with: result.url)
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
        .navigationTitle("Search: \(browserState.rootName ?? "")")
        .focusedSceneValue(\.focusedBrowserState, browserState)
    }

    func startSearch() {
        guard let rootURL = browserState.rootURL else { return }
        searchState.startSearch(rootURL: rootURL, alertState: browserState.alertState)
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
                searchState.isShowSearchWindow = false
            }
            .store(in: &cancellables)
    }

    func saveWindowSize(_ window: NSWindow) {
        appState.saveWindowRect(window.frame, for: "search", uuid: browserState.id)
    }
}

#Preview {
//    SearchView()
}
