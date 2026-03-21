//
//  FileListManager.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 2/26/26.
//

import Foundation
import MyLibrary

@Observable
class FileListManager {
    private(set) var files: [URL] = []

    init() {}

    func update(from url: URL) throws {
        files = try TextFileURLCollector().collectShallowly(from: url)
        files.sort { $0.lastPathComponent < $1.lastPathComponent }
    }
}
