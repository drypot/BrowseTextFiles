//
//  FileState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import Foundation
import UniformTypeIdentifiers

nonisolated struct FileState: Identifiable, Hashable {
    // URL 대신 UUID id 를 사용하면 reload 된 Item 의 URL 이 같아도 item 이 변경되었음을 알릴 수 있다.
    let id = UUID()
    let url: URL
    let name: String

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: FileState, rhs: FileState) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func collectShallowly(from folderURL: URL, filter: (UTType) -> Bool) throws -> [FileState] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey, .contentTypeKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let urls = try fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: keys,
            options: options
        )

        var results: [FileState] = []
        for url in urls {
            try autoreleasepool {
                let values = try url.resourceValues(forKeys: keySet)
                if values.isRegularFile == true {
                    if let contentType = values.contentType {
                        if filter(contentType) {
                            results.append(FileState(from: url))
                        }
                    }
                }
            }
        }

        return results
    }

    static func collectRecursively(from rootURL: URL) throws -> [FileState] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let values = try rootURL.resourceValues(forKeys: keySet)

        if values.isRegularFile == true {
            return [FileState(from: rootURL)]
        }
        if values.isDirectory == true {
            guard let enumerator = fileManager.enumerator(at: rootURL,
                                                          includingPropertiesForKeys: keys,
                                                          options: options) else { return [] }
            var results: [FileState] = []
            for case let url as URL in enumerator {
                try autoreleasepool {
                    let values = try url.resourceValues(forKeys: keySet)
                    if values.isRegularFile == true {
                        results.append(FileState(from: url))
                    }
                }
            }
            return results
        }

        return []
    }
}
