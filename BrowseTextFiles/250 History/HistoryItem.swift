//
//  URLForView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import Foundation

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
