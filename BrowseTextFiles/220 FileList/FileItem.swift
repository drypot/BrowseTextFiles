//
//  FileItem.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import Foundation

nonisolated struct FileItem: Identifiable, Comparable, Hashable {
    let id = UUID()

    var url: URL
    var name: String

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: FileItem, rhs: FileItem) -> Bool {
        return lhs.name < rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
