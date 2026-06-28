//
//  BrowserState+History.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import SwiftUI

extension BrowserState {

    func addToHistory(_ url: URL) {
        let first = history.firstIndex { $0.url == url }
        if first == nil {
            let urlForView = URLForView(url: url)
            history.insert(urlForView, at: 0)
        }
    }

    func clearHistory() {
        history.removeAll()
    }

}
