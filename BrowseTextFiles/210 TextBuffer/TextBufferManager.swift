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

