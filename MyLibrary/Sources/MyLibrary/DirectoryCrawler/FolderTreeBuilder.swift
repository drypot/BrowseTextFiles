//
//  FolderTreeBuilder.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

/*
 Why does FileManager.enumerator use an absurd amount of memory?
 https://stackoverflow.com/questions/46383143/why-does-filemanager-enumerator-use-an-absurd-amount-of-memory
 */

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
