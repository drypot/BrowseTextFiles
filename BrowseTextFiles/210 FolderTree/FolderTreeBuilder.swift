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

struct FolderTreeBuilder {
    init() {}
    
    func buildTree(from rootURL: URL) throws -> FolderItem {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        func buildSubtree(from folderURL: URL) throws -> FolderItem {
            let fileManager = FileManager.default
            let folderItem = FolderItem(from: folderURL)

            let urls = try fileManager.contentsOfDirectory(at: folderURL,
                                                            includingPropertiesForKeys: keys,
                                                            options: options)
            for url in urls {
                try autoreleasepool {
                    let values = try url.resourceValues(forKeys: keySet)
                    if values.isDirectory == true {
                        let childItem = try buildSubtree(from: url)
                        if folderItem.children == nil {
                            folderItem.children = [childItem]
                        } else {
                            folderItem.children!.append(childItem)
                        }
                    }
                }
            }
            folderItem.children?.sort()

            return folderItem
        }

        return try buildSubtree(from: rootURL)
    }
}
