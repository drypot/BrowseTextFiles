//
//  TextBuffer.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MyLibrary

@Observable
public final class TextBuffer: Identifiable, Hashable {
    public var url: URL
    public var name: String

    public var text: String

    public var isEdited: Bool

    public var id: URL { url }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.text = ""
        self.isEdited = false
    }

    var textSetter: String {
        get { text }
        set {
            text = newValue
            isEdited = true
        }
    }

    public func loadContent() throws {
        text = try String(contentsOf: url, encoding: .utf8)
        isEdited = false
    }

    public func saveContent() throws {
//         파일을 이렇게 생성하면 먼저 붙였던 fileMonitor 가 떨어져 나간다.
//         try text.write(to: url, atomically: true, encoding: .utf8)

        guard let data = text.data(using: .utf8) else { return }
        let fileHandle = try FileHandle(forWritingTo: url)
        try fileHandle.seek(toOffset: 0)
        try fileHandle.write(contentsOf: data)
        try fileHandle.truncate(atOffset: UInt64(data.count))
        try fileHandle.synchronize()
        try fileHandle.close()

        isEdited = false
        LogStore.shared.log("TextBuffer: saved, \(self.url.lastPathComponent)")
    }

    public static func == (lhs: TextBuffer, rhs: TextBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
