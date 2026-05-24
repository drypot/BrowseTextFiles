//
//  SearchView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI
import Combine

struct SearchView: View {
    @Environment(AppState.self) var appState
    @Environment(FileBrowserState.self) var state

    @State private var window: NSWindow?
    @State private var cancellables = Set<AnyCancellable>()

    @FocusState var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                @Bindable var searchState = state.search
                TextField("Search", text: $searchState.searchText)
                    .frame(minWidth: 180)
                    .onSubmit {
                        state.search.startSearch()
                    }
                    .focused($isFocused)
                    .task {
                        isFocused = true
                    }
                Button("Search") {
                    state.search.startSearch()
                }
                Button("Reset") {
                    state.search.clearSearchResult()
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 28)
            Divider()

            List {
                if let results = state.search.searchResults, !results.isEmpty {
                    ForEach(results) { result in
                        Group {
                            Button(result.title) {
                                state.updateAll(fromFileURL: result.url)
                            }
                            .buttonStyle(.plain)
                            .fontWeight(.bold)
                            .foregroundStyle(.link)
                            .pointerStyle(.link)

                            ForEach(result.lines) { line in
                                Text(line.text)
                            }
                            Spacer()
                                .frame(height: 8)
                        }
                    }
                    .font(appState.makeFontForText())
                    .lineSpacing(appState.lineSpacing)
                    .listRowSeparator(.hidden)
                    .padding(.horizontal, 10)
                } else {
                    Text("No results")
                        .font(appState.makeFontForText())
                        .lineSpacing(appState.lineSpacing)
                        .padding(.horizontal, 12)
                }
            }
        }
        .background(WindowReader(onResolve: handleWindow))
        .frame(minWidth: 440)
    }

    func handleWindow(_ window: NSWindow?) {
        guard let window else { return }
        self.window = window

        appState.saveSearchWindowSize(window.frame.size, position: window.frame.origin)

        NotificationCenter.default
            .publisher(for: NSWindow.didBecomeMainNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                appState.saveSearchWindowSize(window.frame.size, position: window.frame.origin)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didResizeNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                appState.saveSearchWindowSize(window.frame.size, position: window.frame.origin)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSWindow.didMoveNotification, object: window)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                appState.saveSearchWindowSize(window.frame.size, position: window.frame.origin)
            }
            .store(in: &cancellables)

    }
}

#Preview {
//    SearchView()
}
