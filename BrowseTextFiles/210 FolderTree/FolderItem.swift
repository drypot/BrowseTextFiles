//
//  FolderItem.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

final class FolderItem: Identifiable, Comparable, Hashable {
    let id = UUID()
    
    var url: URL
    var name: String
    var children: [FolderItem]?

    var hasChildren: Bool { children != nil }

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: FolderItem, rhs: FolderItem) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: FolderItem, rhs: FolderItem) -> Bool {
        return lhs.name < rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func findFolder(with url: URL) -> FolderItem? {
        if self.url == url { return self }
        if let children {
            for child in children {
                if let found = child.findFolder(with: url) {
                    return found
                }
            }
        }
        return nil
    }
}

