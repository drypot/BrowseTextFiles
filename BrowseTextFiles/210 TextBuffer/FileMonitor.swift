//
//  FileMonitor.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/5/26.
//

import Foundation

class FileMonitor {
    private var source: DispatchSourceFileSystemObject?

    func startMonitoring(_ url: URL, onChange: @escaping (DispatchSource.FileSystemEvent) -> Void) {
        let fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global()
        )
        guard let source else { return }

        source.setEventHandler { [weak self] in
            guard let self else { return }
            let data = self.source!.data // DispatchSource.FileSystemEvent
            onChange(data)
        }

        source.setCancelHandler {
            close(fileDescriptor)
        }

        source.resume()
    }

    func stopMonitoring() {
        source?.cancel()
    }
}
