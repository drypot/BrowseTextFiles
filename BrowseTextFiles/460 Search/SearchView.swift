//
//  SearchView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct SearchView: View {
    @Environment(BrowserState.self) var browser

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchButtons()
            Divider()

            if let results = browser.search.searchResults, !results.isEmpty {
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
    @Environment(BrowserState.self) var browser

    @FocusState var isFocused: Bool

    var body: some View {
        @Bindable var search = browser.search
        HStack {
            TextField("Search", text: $search.searchText)
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
            //    search.clearSearchResult()
            //}
        }
        .padding(.horizontal)
        .padding(.vertical, 8)

    }

    func startSearch() {
        guard let rootURL = browser.context.rootURL else { return }
        browser.search.startSearch(rootURL: rootURL)
    }
}

fileprivate struct SearchResults: View {
    @Environment(BrowserState.self) var browser

    let results: [SearchResult]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(results) { result in
                    VStack(alignment: .leading) {
                        Button(result.title) {
                            browser.targetFile(result.url)
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
