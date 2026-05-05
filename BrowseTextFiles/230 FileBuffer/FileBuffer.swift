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
final class FileBuffer: Identifiable, Hashable {
    let id = UUID()

    private(set) var url: URL
    private(set) var name: String

    private(set) var text: String = ""
    var selection: TextSelection?

    private(set) var isEdited = false
    var hasSaveError = false
    var loadError: String?

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    func textBinding() -> Binding<String> {
        Binding<String>(
            get: { self.text },
            set: {
                self.text = $0
                self.isEdited = true
            }
        )
    }

    func loadContent() throws {
        text = try String(contentsOf: url, encoding: .utf8)
        isEdited = false
    }

    func saveContent() throws {
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

    static func == (lhs: FileBuffer, rhs: FileBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
