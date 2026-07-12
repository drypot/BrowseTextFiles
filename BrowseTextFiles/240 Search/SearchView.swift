//
//  SearchView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct SearchView: View {
    @Environment(SearchState.self) var searchState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchButtons()
            Divider()

            if let results = searchState.searchResults, !results.isEmpty {
                SearchResults(results: results)
            } else {
                Text("No results")
                    .padding()
                Spacer()
            }
        }
    }
}

fileprivate struct SearchButtons: View {
    @Environment(RootState.self) var rootState
    @Environment(SearchState.self) var searchState

    @FocusState var isFocused: Bool

    var body: some View {
        @Bindable var searchState = searchState
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

    }

    func startSearch() {
        guard let rootURL = rootState.rootURL else { return }
        searchState.startSearch(rootURL: rootURL)
    }
}

fileprivate struct SearchResults: View {
    @Environment(TargetState.self) var targetState

    let results: [SearchResult]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(results) { result in
                    VStack(alignment: .leading) {
                        Button(result.title) {
                            targetState.targetFile(result.url)
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
    }
}
