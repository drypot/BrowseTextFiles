//
//  TextBuffer.swift
//  BrowseTextFiles
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

    public convenience init?(contentsOf url: URL) throws {
        let text = try String(contentsOf: url, encoding: .utf8)
        self.init(url: url, text: text)
    }

    public static func == (lhs: TextBuffer, rhs: TextBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

