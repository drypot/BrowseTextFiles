//
//  TextBufferCache.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/5/26.
//

import Foundation
import MyLibrary

final class TextBufferCache {
    public static let shared = TextBufferCache()

    private var bufferDic: [URL: TextBuffer] = [:]
    private var monitorDic: [URL: FileMonitor] = [:]

    private init() {}

    public func buffer(for url: URL) -> TextBuffer? {
        return bufferDic[url]
    }

    public func addCache(for url: URL) throws -> TextBuffer {
        let buffer = TextBuffer(url: url)
        try buffer.loadContent()
        bufferDic[url] = buffer

//        let fileMonitor = FileMonitor()
//        monitorDic[url] = fileMonitor
//        fileMonitor.startMonitoring(url) { [weak self] data in
//            guard let self else { return }
//            if data.contains(.delete) {
//                print("file monitor: delete, \(url.lastPathComponent)")
//                self.removeBuffer(for: url)
//            }
//            if data.contains(.rename) {
//                print("file monitor: rename, \(url.lastPathComponent)")
//                self.removeBuffer(for: url)
//            }
//            if data.contains(.write) {
//                print("file monitor: write, \(url.lastPathComponent)")
//                if buffer.refCount == 0 {
//                    self.removeBuffer(for: url)
//                    print("file monitor: write, invalidated")
//                } else {
//                    do {
//                        guard let buffer = self.bufferDic[url] else { return }
//                        try buffer.loadContent()
//                        print("file monitor: write, reload")
//                    } catch {
//                        buffer.text = ""
//                    }
//                }
//            }
//        }

        return buffer
    }

//    private func stopMonitoring(_ url: URL) {
//        monitorDic[url]?.stopMonitoring()
//        monitorDic.removeValue(forKey: url)
//    }
//
//    private func removeBuffer(for url: URL) {
//        let buffer = bufferDic.removeValue(forKey: url)
//        if let buffer {
//            buffer.isValid = false
//        }
//
//    }

}
