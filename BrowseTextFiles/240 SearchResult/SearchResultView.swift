//
//  SearchResultView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct SearchResultView: View {
    @Environment(SettingsData.self) var settings

    @Bindable var status: FileBrowserStatus
    @FocusState var isFocused: Bool

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $status.searchText)
                    .frame(width: 320)
                    .focused($isFocused)
                    .onSubmit {
                        status.startSearch()
                    }
                    .onExitCommand {
                        status.hideSearchView()
                    }
                    .onAppear {
                        isFocused = true
                    }

                Button("Search") {
                    status.startSearch()
                }

                Button("Reset") {
                    status.clearSearchResult()
                }
            }
            .padding(.bottom, 16)

            Divider()

            List {
                if let results = status.searchResults, !results.isEmpty {
                    ForEach(results) { result in
                        Group {
                            Button(result.title) {
                                status.updateAll(fromSearchedFile: result.url)
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
                    .font(.custom(settings.fontName, size: settings.fontSize))
                    .lineSpacing(settings.lineSpacing)
                    .listRowSeparator(.hidden)
                } else {
                    Text("No results")
                        .font(.custom(settings.fontName, size: settings.fontSize))
                        .lineSpacing(settings.lineSpacing)
                }
            }
            .onExitCommand {
                status.hideSearchView()
            }
        }
    }
}

#Preview {
//    SearchResultView()
}
