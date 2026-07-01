//
//  HistoryState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/1/26.
//

import SwiftUI

struct HistoryItem: Identifiable, Hashable {
    let url: URL
    let path: String
    let pathComponents: [String]

    var id: URL { url }

    init(url: URL) {
        self.url = url
        self.path = url.path(percentEncoded: false)
        self.pathComponents = url.pathComponents
    }

    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func relativePath(from rootComponents: [String]) -> String {
        if pathComponents.starts(with: rootComponents) {
            return pathComponents.dropFirst(rootComponents.count).joined(separator: "/")
        } else {
            return path
        }
    }
}

@Observable
final class HistoryState {
    var history: [HistoryItem] = []
    var isHistoryWindowShown = false

    func addToHistory(_ url: URL) {
        let first = history.firstIndex { $0.url == url }
        if first == nil {
            let historyItem = HistoryItem(url: url)
            history.insert(historyItem, at: 0)
        }
    }

    func clearHistory() {
        history.removeAll()
    }
}
