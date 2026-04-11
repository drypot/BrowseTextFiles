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

    public var isValid: Bool
    public var isEdited: Bool

    public var id: URL { url }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.text = ""
        self.isValid = true
        self.isEdited = false
    }

    public func loadContent() throws {
        self.text = try String(contentsOf: url, encoding: .utf8)
        trackTextChange()
    }

    private func trackTextChange() {
        withObservationTracking {
            _ = self.text
        } onChange: {
            Task { @MainActor in
                self.isEdited = true
                LogStore.shared.log("TextBuffer: edited, \(self.url.lastPathComponent)")
            }
        }
    }

    public func saveContent() throws {
         try text.write(to: url, atomically: true, encoding: .utf8)

//        guard let data = text.data(using: .utf8) else { return }
//        let fileHandle = try FileHandle(forWritingTo: url)
//        try fileHandle.seek(toOffset: 0)
//        try fileHandle.write(contentsOf: data)
//        try fileHandle.truncate(atOffset: UInt64(data.count))
//        try fileHandle.synchronize()
//        try fileHandle.close()

        isEdited = false
        LogStore.shared.log("TextBuffer: saved, \(self.url.lastPathComponent)")
        trackTextChange()
    }

    public static func == (lhs: TextBuffer, rhs: TextBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

