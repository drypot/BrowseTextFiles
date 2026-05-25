//
//  FolderTreeBuilder.swift
//  BrowseTextFiles
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
    
    func buildTree(from rootURL: URL) throws -> FolderForView {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        func buildSubtree(from folderURL: URL) throws -> FolderForView {
            let fileManager = FileManager.default
            let folder = FolderForView(from: folderURL)
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
