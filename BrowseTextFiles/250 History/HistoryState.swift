//
//  HistoryState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/1/26.
//

import SwiftUI

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
