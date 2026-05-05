//
//  Folder.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

final class Folder: Identifiable, Comparable, Hashable {
    // Root 폴더 새로 생성시 TreeView 가 리프레쉬 되게 하기 위해
    // URL 에서 UUID 로 id 를 변경한다.
    let id = UUID()
    
    var url: URL
    var name: String
    var folders: [Folder]?

    var hasChildren: Bool { folders != nil }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.name < rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func findFolder(with url: URL) -> Folder? {
        if self.url == url { return self }
        if let folders {
            for folder in folders {
                if let found = folder.findFolder(with: url) {
                    return found
                }
            }
        }
        return nil
    }
}

