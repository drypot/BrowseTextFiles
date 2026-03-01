//
//  TextBuffer.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers

@Observable
public final class TextBuffer: Identifiable, Hashable {
    public var url: URL
    public var name: String
    public var text: String
    public var refCount: Int

    public var id: URL { url }

    public init(url: URL, text: String) {
        self.url = url
        self.name = url.lastPathComponent
        self.text = text
        self.refCount = 0
    }

    public static func == (lhs: TextBuffer, rhs: TextBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor @Observable
public class TextBufferManager {
    public private(set) var files: [TextBuffer] = []
    private var fileDic: [URL: TextBuffer] = [:]

    @MainActor private static var sharedDic: [URL: TextBuffer] = [:]

    public init() {}
    
    public func file(for url: URL) -> TextBuffer? {
        if let file = fileDic[url] {
            return file
        } else if let file = Self.sharedDic[url] {
            file.refCount += 1
            files.append(file)
            fileDic[url] = file
            return file
        } else {
            return nil
        }
    }

    public func addFile(from url: URL) throws -> TextBuffer {
        let text = try String(contentsOf: url, encoding: .utf8)
        let file = TextBuffer(url: url, text: text)

        Self.sharedDic[url] = file

        file.refCount += 1
        files.append(file)
        fileDic[url] = file

        return file
    }
}

