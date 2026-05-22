//
//  FolderForView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

final class FolderForView: Identifiable, Comparable, Hashable {
    // URL 대신 UUID id 를 사용하면 reload 된 Item 의 URL 이 같아도 item 이 변경되었음을 알릴 수 있다.
    let id = UUID()
    
    var url: URL
    var name: String
    var children: [FolderForView]?

    var hasChildren: Bool { children != nil }

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: FolderForView, rhs: FolderForView) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: FolderForView, rhs: FolderForView) -> Bool {
        return lhs.name < rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func findFolder(withPath path: String) -> FolderForView? {
        if self.url.path == path { return self }
        if let children {
            for child in children {
                if let found = child.findFolder(withPath: path) {
                    return found
                }
            }
        }
        return nil
    }

    func findFolder(withID id: ID) -> FolderForView? {
        if self.id == id { return self }
        if let children {
            for child in children {
                if let found = child.findFolder(withID: id) {
                    return found
                }
            }
        }
        return nil
    }
}

