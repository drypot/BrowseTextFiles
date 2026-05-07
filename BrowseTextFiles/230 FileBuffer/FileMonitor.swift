//
//  FileMonitor.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 4/5/26.
//

import Foundation

nonisolated final class FileMonitor {
    private var source: DispatchSourceFileSystemObject?
    var ignoreEvent = false

    init() {}

    deinit {
        cancel()
    }

    func startMonitoring(_ url: URL, onChange: @escaping (DispatchSource.FileSystemEvent) -> Void) {
        let fd = open(url.path, O_EVTONLY)
        guard fd != -1 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global()
        )

        self.source = source

        source.setEventHandler { [weak self] in
            guard let self else { return }
            guard let data = self.source?.data else { return } // DispatchSource.FileSystemEvent
            // print("FileMonitor: eventHandler, ignoreEvent == \(ignoreEvent)")
            if !ignoreEvent {
                onChange(data)
            }
        }

        source.setCancelHandler {
            // DispatchSource의 cancel()은 비동기 동작이다.
            // source.cancel() 한다음 close(fd) 하면 cancel 처리 전에 fd 가 closed 될 수 있다.
            // fd close 는 cancelHandler 에서 하도록 한다.
            close(fd)
            // print("FileMonitor: closed, \(url.lastPathComponent)")
        }

        source.resume()
        // print("FileMonitor: started, \(url.lastPathComponent)")
    }

//    suspend 를 하면 event handler 콜을 잠시 미룰 뿐 event 는 큐에 계속 쌓인다.
//    resume 을 하면 쌓였던 event 가 한꺼번에 handler 에게 넘어간다.
//    파일 저장시 잠시 모니터링을 멈추는 용도로는 쓸 수 없다.

//    func suspend() {
//        guard let source else { return }
//        source.suspend()
//    }
//
//    func resume() {
//        guard let source else { return }
//        source.resume()
//    }

    func cancel() {
        guard let source else { return }
        source.cancel()
        self.source = nil
    }

    func disableMonitoringWhile<T>(block: () throws -> T) throws -> T {
        // print("FileMonitor: ignoreEvent <- true")
        ignoreEvent = true
        defer {
            // print("FileMonitor: ignoreEvent <- false")
            ignoreEvent = false
        }
        return try block()
    }
}
