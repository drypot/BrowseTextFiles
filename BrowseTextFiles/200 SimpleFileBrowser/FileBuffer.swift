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

    init(url: URL, text: String) throws {
        self.url = url
        self.name = url.lastPathComponent
        self.text = text
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
        let text = try String(contentsOf: url, encoding: .utf8)
        let buffer = try FileBuffer(url: url, text: text)
        buffers[url] = buffer
        buffer.refCount += 1

        return buffer
    }
}

