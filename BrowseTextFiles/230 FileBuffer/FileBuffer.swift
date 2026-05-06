//
//  FileBuffer.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers
import MyLibrary

enum FileBufferError: Error, LocalizedError {
    case hasLoadingError(String)

    var errorDescription: String? {
        switch self {
        case .hasLoadingError(let message):
            return message
        }
    }
}

@Observable
final class FileBuffer: Identifiable, Hashable {
    let id = UUID()

    private(set) var url: URL
    private(set) var name: String

    private(set) var text: String = ""
    private(set) var isEdited = false
    var selection: TextSelection?

    private(set) var loadingError: String?
    var hasLoadingError: Bool {
        loadingError != nil
    }

    private(set) var hasSavingError = false

    private var fileMonitor: FileMonitor?

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    func textBinding() -> Binding<String> {
        Binding<String>(
            get: { self.text },
            set: {
                self.text = $0
                self.isEdited = true
            }
        )
    }

    func loadFile() throws {
        do {
            text = try String(contentsOf: url, encoding: .utf8)
            isEdited = false
        } catch {
            let message = error.localizedDescription
            loadingError = message
            throw error
        }
    }

    func startMonitoring() {
        fileMonitor = FileMonitor()
        fileMonitor!.startMonitoring(url) { [weak self] _ in
            guard let self else { return }
            do {
                try self.loadFile()
            } catch {
                fileMonitor = nil
            }
        }
    }

    func saveFile() throws {
        if hasLoadingError {
            throw FileBufferError.hasLoadingError(loadingError!)
        }

        if let fileMonitor {
            try fileMonitor.disableMonitoringWhile {
                try saveFileCore()
            }
        } else {
            try saveFileCore()
        }
    }

    private func saveFileCore() throws {
        // 파일을 이렇게 생성하면 먼저 붙였던 fileMonitor 가 떨어져 나간다.
        // try text.write(to: url, atomically: true, encoding: .utf8)

        guard let data = text.data(using: .utf8) else { return }

        hasSavingError = true
        let fileHandle = try FileHandle(forWritingTo: url)
        try fileHandle.truncate(atOffset: 0)
        try fileHandle.write(contentsOf: data)
        try fileHandle.close()

        hasSavingError = false
        isEdited = false
    }

    static func == (lhs: FileBuffer, rhs: FileBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
