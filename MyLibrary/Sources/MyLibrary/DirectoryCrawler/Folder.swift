//
//  Folder.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

/*
 Why does FileManager.enumerator use an absurd amount of memory?
 https://stackoverflow.com/questions/46383143/why-does-filemanager-enumerator-use-an-absurd-amount-of-memory
 */

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
}

public struct FolderTreeBuilder {
    public init() {}
    
    public func build(from url: URL) throws -> Folder {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        func buildFolder(from url: URL) throws -> Folder {
            let fileManager = FileManager.default
            let folder = Folder(url: url)

            let items = try fileManager.contentsOfDirectory(at: url,
                                                            includingPropertiesForKeys: keys,
                                                            options: options)
            for item in items {
                try autoreleasepool {
                    let values = try item.resourceValues(forKeys: keySet)
                    if values.isDirectory == true {
                        let child = try buildFolder(from: item)
                        if folder.folders == nil {
                            folder.folders = [child]
                        } else {
                            folder.folders!.append(child)
                        }
                    }
                }
            }
            folder.folders?.sort()

            return folder
        }

        return try buildFolder(from: url)
    }
}
