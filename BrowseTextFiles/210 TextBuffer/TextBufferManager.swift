//
//  TextBufferManager.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers

@MainActor @Observable
public class TextBufferManager {
    public private(set) var buffers: [TextBuffer] = []
    private var bufferDic: [URL: TextBuffer] = [:]

    @MainActor private static var sharedDic: [URL: TextBuffer] = [:]

    public init() {}
    
    public func buffer(for url: URL) -> TextBuffer? {
        if let buffer = bufferDic[url] {
            return buffer
        } else if let buffer = Self.sharedDic[url] {
            buffer.refCount += 1
            buffers.append(buffer)
            bufferDic[url] = buffer
            return buffer
        } else {
            return nil
        }
    }

    public func addBuffer(contentOf url: URL) throws -> TextBuffer {
        let text = try String(contentsOf: url, encoding: .utf8)
        let buffer = TextBuffer(url: url, text: text)

        Self.sharedDic[url] = buffer

        buffer.refCount += 1
        buffers.append(buffer)
        bufferDic[url] = buffer

        return buffer
    }
}

