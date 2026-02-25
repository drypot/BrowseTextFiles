//
//  FileBuffer.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 2/19/26.
//

import Foundation

@Observable
final class FileBuffer: Identifiable, Hashable {
    var url: URL
    var name: String
    var text: String
    var refCount: Int

    var id: URL { url }

    init(url: URL) throws {
        self.url = url
        self.name = url.lastPathComponent
        self.text = try String(contentsOf: url, encoding: .utf8)
        self.refCount = 0
    }

    static func == (lhs: FileBuffer, rhs: FileBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable
class FileBufferManager {
    private var buffers: [URL: FileBuffer] = [:]

    func buffer(for url: URL) -> FileBuffer? {
        return buffers[url]
    }

    func addBuffer(for url: URL) throws -> FileBuffer {
        let buffer = try FileBuffer(url: url)
        buffers[url] = buffer
        buffer.refCount += 1

        return buffer
    }
}

