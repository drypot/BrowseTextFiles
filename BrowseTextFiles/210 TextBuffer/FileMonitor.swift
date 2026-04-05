//
//  FileMonitor.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/5/26.
//

import Foundation

class FileMonitor {
    private var fileDescriptor: Int32 = -1
    private var source: DispatchSourceFileSystemObject?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func startMonitoring(onChange: @escaping (DispatchSource.FileSystemEvent) -> Void) {
        fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global()
        )
        self.source = source

        source.setEventHandler { [weak self] in
            guard let self else { return }
            let data = self.source!.data // DispatchSource.FileSystemEvent
            onChange(data)
        }

        source.setCancelHandler { [weak self] in
            guard let self else { return }
            close(self.fileDescriptor)
        }

        source.resume()
    }

    func stopMonitoring() {
        source?.cancel()
    }
}
