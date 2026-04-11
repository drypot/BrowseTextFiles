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

    private let log = LogStore.shared.log

    private init() {}

    public func buffer(for url: URL) -> TextBuffer? {
        return bufferDic[url]
    }

    public func addCache(for url: URL) throws -> TextBuffer {
        let buffer = TextBuffer(url: url)
        try buffer.loadContent()
        bufferDic[url] = buffer

        let fileMonitor = FileMonitor()
        monitorDic[url] = fileMonitor
        fileMonitor.startMonitoring(url) { [weak self] data in
            guard let self else { return }

            if data.contains(.delete) {
                log("file monitor: delete, \(url.lastPathComponent)")
            }
            if data.contains(.rename) {
                log("file monitor: rename, \(url.lastPathComponent)")
            }
            if data.contains(.write) {
                log("file monitor: write, \(url.lastPathComponent)")
            }

            if let buffer = self.bufferDic.removeValue(forKey: url) {
                buffer.isValid = false
            }
            if let monitor = self.monitorDic.removeValue(forKey: url) {
                monitor.stopMonitoring()
            }
        }

        return buffer
    }
}
