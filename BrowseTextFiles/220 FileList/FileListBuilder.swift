//
//  FileListBuilder.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 2/28/26.
//

import Foundation
import UniformTypeIdentifiers

nonisolated struct FileListBuilder {
    init() {}

    func collectShallowly(from folderURL: URL, filter: (UTType) -> Bool) throws -> [FileItem] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey, .contentTypeKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let urls = try fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: keys,
            options: options
        )

        var results: [FileItem] = []
        for url in urls {
            try autoreleasepool {
                let values = try url.resourceValues(forKeys: keySet)
                if values.isRegularFile == true {
                    if let contentType = values.contentType {
                        if filter(contentType) {
                            results.append(FileItem(from: url))
                        }
                    }
                }
            }
        }

        return results
    }

    func collectRecursively(from rootURL: URL) throws -> [FileItem] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let values = try rootURL.resourceValues(forKeys: keySet)

        if values.isRegularFile == true {
            return [FileItem(from: rootURL)]
        }
        if values.isDirectory == true {
            guard let enumerator = fileManager.enumerator(at: rootURL,
                                                          includingPropertiesForKeys: keys,
                                                          options: options) else { return [] }
            var results: [FileItem] = []
            for case let url as URL in enumerator {
                try autoreleasepool {
                    let values = try url.resourceValues(forKeys: keySet)
                    if values.isRegularFile == true {
                        results.append(FileItem(from: url))
                    }
                }
            }
            return results
        }
        
        return []
    }
}
