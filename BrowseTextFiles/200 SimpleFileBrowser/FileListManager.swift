//
//  FileListManager.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 2/26/26.
//

import Foundation

class File: Identifiable, Hashable {
    let url: URL
    let name: String

    var id: URL { url }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: File, rhs: File) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable
class FileListManager {
    var files: [File] = []

    init() {
    }

    func removeAll() {
        files = []
    }

    func update(from url: URL, root: URL) throws {
        files = try TextFileListBuilder().build(from: url, root: root)
    }
}

struct TextFileListBuilder {
    func build(from url: URL, root: URL) throws -> [File] {
        let fileManager = FileManager.default
        var files: [File] = []

        let keys: [URLResourceKey] = [.isRegularFileKey, .contentTypeKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        guard root.startAccessingSecurityScopedResource() else { return [] }
        defer { root.stopAccessingSecurityScopedResource() }

        var urls = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: keys,
            options: options
        )
        urls.sort { $0.lastPathComponent < $1.lastPathComponent }

        for url in urls {
            try autoreleasepool {
                let values = try url.resourceValues(forKeys: keySet)
                if values.isRegularFile == true,
                   let contentType = values.contentType,
                   contentType.conforms(to: .text) {
                    files.append(File(url: url))
                }
            }
        }

        return files
    }
}
