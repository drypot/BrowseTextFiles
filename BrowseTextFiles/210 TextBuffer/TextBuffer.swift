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

    private var fileMonitor: FileMonitor?

    public var id: URL { url }

    public init(url: URL, text: String) {
        self.url = url
        self.name = url.lastPathComponent
        self.text = text
        self.isValid = true
    }

    public convenience init(contentsOf url: URL) throws {
        let text = try String(contentsOf: url, encoding: .utf8)
        self.init(url: url, text: text)
    }

    public func startMonitoring() {
        fileMonitor = FileMonitor(url: url)
        fileMonitor?.startMonitoring { [weak self] data in
            guard let self else { return }
            if data.contains(.delete) {
                print("file monitor event: delete, \(self.url.lastPathComponent)")
                self.isValid = false
            }
            if data.contains(.rename) {
                print("file monitor event: rename, \(self.url.lastPathComponent)")
                self.isValid = false
            }
            if data.contains(.write) {
                print("file monitor event: write, \(self.url.lastPathComponent)")
                do {
                    self.text = try String(contentsOf: url, encoding: .utf8)
                } catch {
                    self.text = ""
                }
            }
        }
    }

    public func stopMonitoring() {
        self.fileMonitor?.stopMonitoring()
    }

    public static func == (lhs: TextBuffer, rhs: TextBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

