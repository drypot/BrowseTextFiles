//
//  FileURL.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 2/28/26.
//

import Foundation

public struct FileURLCollector {
    public init() {}

    public func collectShallowly(from url: URL) throws -> [URL] {
        let fileManager = FileManager.default
        var results: [URL] = []

        let keys: [URLResourceKey] = [.isRegularFileKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let items = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: keys,
            options: options
        )

        for item in items {
            try autoreleasepool {
                let values = try item.resourceValues(forKeys: keySet)
                if values.isRegularFile == true {
                    results.append(item)
                }
            }
        }

        return results
    }

    public func collectRecursively(from urls: [URL]) throws -> [URL] {
        let fileManager = FileManager.default
        var results: [URL] = []

        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        for url in urls {
            let values = try url.resourceValues(forKeys: keySet)
            if values.isRegularFile == true {
                results.append(url)
            } else if values.isDirectory == true {
                guard let enumerator = fileManager.enumerator(at: url,
                                                              includingPropertiesForKeys: keys,
                                                              options: options) else { continue }
                for case let item as URL in enumerator {
                    try autoreleasepool {
                        let values = try item.resourceValues(forKeys: keySet)
                        if values.isRegularFile == true {
                            results.append(item)
                        }
                    }
                }
            }
        }

        return results
    }

    public func collectRecursively(from url: URL) throws -> [URL] {
        return try collectRecursively(from: [url])
    }
}
