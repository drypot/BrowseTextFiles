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
    public var isValid: Bool

//    private var fileMonitor: FileMonitor?

    public var id: URL { url }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.text = ""
        self.refCount = 0
        self.isValid = true
    }

    public func loadContent() throws {
        self.text = try String(contentsOf: url, encoding: .utf8)
    }

//    public func startMonitoring() {
//        fileMonitor = FileMonitor()
//        fileMonitor?.startMonitoring(url) { [weak self] data in
//            guard let self else { return }
//            if data.contains(.delete) {
//                print("file monitor: delete, \(self.url.lastPathComponent)")
//                self.isValid = false
//            }
//            if data.contains(.rename) {
//                print("file monitor: rename, \(self.url.lastPathComponent)")
//                self.isValid = false
//            }
//            if data.contains(.write) {
//                print("file monitor: write, \(self.url.lastPathComponent)")
//                if refCount == 0 {
//                    self.isValid = false
//                    print("file monitor: write, invalidated")
//                } else {
//                    do {
//                        try self.loadContent()
//                        print("file monitor: write, reload")
//                    } catch {
//                        self.text = ""
//                    }
//                }
//            }
//        }
//    }

//    public func stopMonitoring() {
//        self.fileMonitor?.stopMonitoring()
//    }

    public static func == (lhs: TextBuffer, rhs: TextBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

