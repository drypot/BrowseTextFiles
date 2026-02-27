//
//  FileBufferManager.swift
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

    init(url: URL, text: String) {
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
    var buffers: [FileBuffer] = []
    var bufferDic: [URL: FileBuffer] = [:]

    private static var sharedDic: [URL: FileBuffer] = [:]

    func addBuffer(for url: URL, root: URL) throws -> FileBuffer {
        if let buffer = bufferDic[url] {
            return buffer
        } else if let buffer = Self.sharedDic[url] {
            buffer.refCount += 1
            buffers.append(buffer)
            bufferDic[url] = buffer
            return buffer
        } else {
            guard root.startAccessingSecurityScopedResource() else { throw AppError.fileOpenError }
            defer { root.stopAccessingSecurityScopedResource() }

            let text = try String(contentsOf: url, encoding: .utf8)
            let buffer = FileBuffer(url: url, text: text)
            buffer.refCount += 1
            buffers.append(buffer)
            bufferDic[url] = buffer
            Self.sharedDic[url] = buffer
            return buffer
        }
    }

}

