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
            HStack {
                Spacer()
                Button("Clear") {
                    historyState.clearHistory()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            if !historyState.history.isEmpty {
                HistoryListView()
            } else {
                Spacer()
            }
        }
    }
}

fileprivate struct HistoryListView: View {
    @Environment(TargetState.self) var targetState
    @Environment(RootState.self) var rootState
    @Environment(HistoryState.self) var historyState

    var body: some View {
        let rootComponents = rootState.rootURL?.pathComponents ?? []
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(historyState.history) { historyItem in
                    let path = historyItem.relativePath(from: rootComponents)
                    Button(path) {
                        targetState.targetFile(historyItem.url)
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
