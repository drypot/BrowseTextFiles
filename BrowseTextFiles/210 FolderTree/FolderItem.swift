//
//  FolderItem.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

final class FolderItem: Identifiable, Comparable, Hashable {
    // URL 대신 UUID id 를 사용하면 reload 된 Item 의 URL 이 같아도 item 이 변경되었음을 알릴 수 있다.
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

    func findFolder(with id: ID) -> FolderItem? {
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

