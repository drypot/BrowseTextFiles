//
//  FolderState.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

final class FolderState: Identifiable, Hashable {
    // URL 대신 UUID id 를 사용하면 reload 된 Item 의 URL 이 같아도 item 이 변경되었음을 알릴 수 있다.
    let id = UUID()
    let url: URL
    let name: String
    var children: [FolderState]?

    var hasChildren: Bool { children != nil }

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: FolderState, rhs: FolderState) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func findFolder(with path: String) -> FolderState? {
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

    func findFolder(with id: ID) -> FolderState? {
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

    static func buildTree(from rootURL: URL) throws -> FolderState {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        func buildSubtree(from folderURL: URL) throws -> FolderState {
            let fileManager = FileManager.default
            let folder = FolderState(from: folderURL)
            let urls = try fileManager.contentsOfDirectory(at: folderURL,
                                                           includingPropertiesForKeys: keys,
                                                           options: options)
            for url in urls {
                try autoreleasepool {
                    let values = try url.resourceValues(forKeys: keySet)
                    if values.isDirectory == true {
                        let childItem = try buildSubtree(from: url)
                        if folder.children == nil {
                            folder.children = [childItem]
                        } else {
                            folder.children!.append(childItem)
                        }
                    }
                }
            }
            folder.children?.sort {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }

            return folder
        }

        return try buildSubtree(from: rootURL)
    }
}

