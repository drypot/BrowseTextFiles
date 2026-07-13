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
    @Environment(BrowserState.self) var browserState
    @Environment(SearchState.self) var searchState

    @FocusState var isFocused: Bool

    var body: some View {
        @Bindable var searchState = searchState
        HStack {
            TextField("Search", text: $searchState.searchText)
                .frame(maxWidth: .infinity)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
                .onSubmit {
                    startSearch()
                }
            //Button("Search") {
            //    startSearch()
            //}
            //Button("Reset") {
            //    searchState.clearSearchResult()
            //}
        }
        .padding(.horizontal)
        .padding(.vertical, 8)

    }

    func startSearch() {
        guard let rootURL = browserState.rootURL else { return }
        searchState.startSearch(rootURL: rootURL)
    }
}

fileprivate struct SearchResults: View {
    @Environment(BrowserState.self) var browserState

    let results: [SearchResult]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(results) { result in
                    VStack(alignment: .leading) {
                        Button(result.title) {
                            browserState.targetFile(result.url)
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
