//
//  SearchResultView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct SearchResultView: View {
    @Environment(AppState.self) var appState

    @Bindable var state: FileBrowserState
    @FocusState var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search", text: $state.searchText)
                    .frame(width: 320)
                    .focused($isFocused)
                    .onSubmit {
                        let findPasteboard = NSPasteboard(name: .find)
                        findPasteboard.declareTypes([.string], owner: nil)
                        findPasteboard.setString(state.searchText, forType: .string)

                        state.startSearch()
                    }
                    .onAppear {
                        isFocused = true
                    }

                Button("Search") {
                    state.startSearch()
                }

                Button("Reset") {
                    state.clearSearchResult()
                }
            }
            .padding(.vertical, 24)

            Divider()

            List {
                if let results = state.searchResults, !results.isEmpty {
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
                    .font(.custom(appState.fontName, size: appState.fontSize))
                    .lineSpacing(appState.lineSpacing)
                    .listRowSeparator(.hidden)
                } else {
                    Text("No results")
                        .font(.custom(appState.fontName, size: appState.fontSize))
                        .lineSpacing(appState.lineSpacing)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
//    SearchResultView()
}
