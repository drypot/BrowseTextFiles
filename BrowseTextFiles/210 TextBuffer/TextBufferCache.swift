//
//  TextBufferCache.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/5/26.
//

import Foundation
import MyLibrary

// 케쉬는 쓰지 않는 것으로.
// 여러 윈도우에서 쓸 때 화면 업데이트의 복잡함, 엉킴, 처리 귀찮음.

@available(*, deprecated)
final class TextBufferCache {
    public static let shared = TextBufferCache()

    private var bufferDic: [URL: TextBuffer] = [:]

//  파일 모니터링 기능은 쓰지 않는 것으로.
//  이유는, 그냥 기능 최소화;

//    private var monitorDic: [URL: FileMonitor] = [:]

    private let log = LogStore.shared.log

    private init() {}

    public func reset() {
//        for monitor in monitorDic {
//            monitor.value.cancel()
//        }
//        monitorDic = [:]

        for buffer in bufferDic {
            buffer.value.isValid = false
        }
        bufferDic = [:]

        log("TextCache: reset")
    }

    public func buffer(for url: URL, rootURL: URL) throws -> TextBuffer {
        if let buffer = bufferDic[url] {
            log("TextCache: buffer found in cache, \(url.lastPathComponent)")
            return buffer
        }

        return try withSecurityScope(rootURL) {
            let buffer = try addBuffer(for: url)
//            addMonitor(for: url)
            log("TextCache: buffer created, \(url.lastPathComponent)")
            return buffer
        }
    }

    private func addBuffer(for url: URL) throws -> TextBuffer {
        let buffer = TextBuffer(url: url)
        try buffer.loadContent()
        bufferDic[url] = buffer
        return buffer
    }

//    private func addMonitor(for url: URL) {
//        let fileMonitor = FileMonitor()
//        monitorDic[url] = fileMonitor
//        fileMonitor.startMonitoring(url) { [weak self] data in
//            guard let self else { return }
//
//            if data.contains(.delete) {
//                log("FileMonitor: delete, \(url.lastPathComponent)")
//            }
//            if data.contains(.rename) {
//                log("FileMonitor: rename, \(url.lastPathComponent)")
//            }
//            if data.contains(.write) {
//                log("FileMonitor: write, \(url.lastPathComponent)")
//            }
//
//            if let buffer = self.bufferDic.removeValue(forKey: url) {
//                buffer.isValid = false
//            }
//            if let monitor = self.monitorDic.removeValue(forKey: url) {
//                monitor.cancel()
//            }
//        }
//    }
//
//    private func removeMonitor(for url: URL) {
//        if let monitor = self.monitorDic.removeValue(forKey: url) {
//            monitor.cancel()
//        }
//    }

    func saveBuffer(_ buffer: TextBuffer, rootURL: URL) throws {
        try withSecurityScope(rootURL) {
//            let url = buffer.url
//            removeMonitor(for: url)
            try buffer.saveContent()
//            addMonitor(for: url)
        }
    }
}
