//
//  HistoryView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct HistoryView: View {
    @Environment(HistoryState.self) var historyState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !historyState.history.isEmpty {
                HistoryListView()
            } else {
                Spacer()
            }

            Divider()

            HStack {
                Button("Clear") {
                    historyState.clearHistory()
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

fileprivate struct HistoryListView: View {
    @Environment(BrowserState.self) var browser

    var body: some View {
        let rootComponents = browser.context.rootURL?.pathComponents ?? []
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(browser.history.history) { historyItem in
                    let path = historyItem.relativePath(from: rootComponents)
                    Button(path) {
                        browser.targetFile(historyItem.url)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.link)
                .pointerStyle(.link)
                .padding(.horizontal)
            }
            .padding(.vertical, 16)
        }
    }
}
