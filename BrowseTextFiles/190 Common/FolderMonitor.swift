//
//  FolderMonitor.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/26/26.
//

import Foundation
import CoreServices

// root folder watch 하면 자동 저장 시에도 이벤트가 발생한다.
// 이것저것 일이 커질 듯하다.
// auto reload 는 먼 훗날 만드는 것으로;

final class FolderWatcher {
    private var stream: FSEventStreamRef?
    private var onChange: (() -> Void)?

    func startWatching(_ url: URL, onChange: @escaping () -> Void) {
        let path = url.path(percentEncoded: false)
        let paths = [path] as CFArray
        let latency: CFTimeInterval = 1.0

        self.onChange = onChange

        var context = FSEventStreamContext(
            version: 0,
            info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: FSEventStreamCallback = { (
            streamRef,
            clientCallBackInfo,
            numEvents,
            eventPaths,
            eventFlags,
            eventIds
        ) in
            // 이 안에서 인자로 받은 onChange 라든가 Task 라든가
            // 다른 Swift 코드 호출하면 컴파일러가 컴파일하다 죽는다;
            // C 코드류만 호출하도록 하자;

            let watcher = Unmanaged<FolderWatcher>
                .fromOpaque(clientCallBackInfo!)
                .takeUnretainedValue()

            DispatchQueue.main.async {
                watcher.onChange?()
            }
        }

        stream = FSEventStreamCreate(
            nil,
            callback,
            &context,
            paths,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            latency,
            UInt32(
                kFSEventStreamCreateFlagFileEvents |
                kFSEventStreamCreateFlagUseCFTypes
            )
        )

        guard let stream else { return }

        FSEventStreamSetDispatchQueue(stream, DispatchQueue.global())
        FSEventStreamStart(stream)
    }

    func stopWatching() {
        guard let stream else { return }

        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
    }
}
