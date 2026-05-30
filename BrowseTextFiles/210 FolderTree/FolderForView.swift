//
//  FolderForView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

final class FolderForView: Identifiable, Hashable {
    // URL 대신 UUID id 를 사용하면 reload 된 Item 의 URL 이 같아도 item 이 변경되었음을 알릴 수 있다.
    let id = UUID()
    let url: URL
    let name: String
    var children: [FolderForView]?

    var hasChildren: Bool { children != nil }

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: FolderForView, rhs: FolderForView) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func findFolder(with path: String) -> FolderForView? {
        if self.url.path == path { return self }
        if let children {
            for child in children {
                if let found = child.findFolder(with: path) {
                    return found
                }
            }
        }
        return nil
    }

    func findFolder(with id: ID) -> FolderForView? {
        if self.id == id { return self }
        if let children {
            for child in children {
                if let found = child.findFolder(with: id) {
                    return found
                }
            }
        }
        return nil
    }
}

