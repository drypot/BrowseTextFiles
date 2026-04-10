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

    public var isValid: Bool

    public var id: URL { url }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.text = ""
        self.isValid = true
    }

    public func loadContent() throws {
        self.text = try String(contentsOf: url, encoding: .utf8)
    }

    public static func == (lhs: TextBuffer, rhs: TextBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

