//
//  Folder.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

public final class Folder: Identifiable, Comparable, Hashable {
    public var url: URL
    public var name: String
    public var folders: [Folder]?

    public var id: URL { url }

    public init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    public static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
    }

    public static func < (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.name < rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public func findFolder(with url: URL) -> Folder? {
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

