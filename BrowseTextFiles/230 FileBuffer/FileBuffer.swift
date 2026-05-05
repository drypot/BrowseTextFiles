//
//  FileBuffer.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers
import MyLibrary

@Observable
public final class FileBuffer: Identifiable, Hashable {
    public var url: URL
    public var name: String

    public var text: String = ""
    public var selection: TextSelection?

    public var isEdited = false
    public var hasSaveError = false
    public var loadError: String?

    public var id: URL { url }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
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

        hasSaveError = true
        let fileHandle = try FileHandle(forWritingTo: url)
        try fileHandle.truncate(atOffset: 0)
        try fileHandle.write(contentsOf: data)
        try fileHandle.close()

        hasSaveError = false
        isEdited = false
    }

    public static func == (lhs: FileBuffer, rhs: FileBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
