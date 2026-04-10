//
//  FileMonitor.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 4/5/26.
//

import Foundation

public final class FileMonitor {
    private var source: DispatchSourceFileSystemObject?

    public init() {}

    public func startMonitoring(_ url: URL, onChange: @escaping (DispatchSource.FileSystemEvent) -> Void) {
        let fd = open(url.path, O_EVTONLY)
        guard fd != -1 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global()
        )
        self.source = source

        source.setEventHandler { [weak self] in
            guard let data = self?.source?.data else { return } // DispatchSource.FileSystemEvent
            onChange(data)
        }

        source.setCancelHandler {
            close(fd)
        }

        source.resume()
    }

    public func stopMonitoring() {
        source?.cancel()
    }
}
