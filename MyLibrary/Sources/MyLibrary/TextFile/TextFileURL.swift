//
//  TextFile.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers

public struct TextFileURLCollector {
    public init() {}
    
    public func collectShallowly(from url: URL) throws -> [URL] {
        let fileManager = FileManager.default
        var results: [URL] = []

        let keys: [URLResourceKey] = [.isRegularFileKey, .contentTypeKey]
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
                if values.isRegularFile == true,
                   let contentType = values.contentType,
                   contentType.conforms(to: .text) {
                    results.append(item)
                }
            }
        }

        return results
    }
}
