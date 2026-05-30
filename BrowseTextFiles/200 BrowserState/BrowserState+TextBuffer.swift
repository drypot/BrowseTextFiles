//
//  BrowserState+TextBuffer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {
    // MARK: - TextBuffer

    var hasFileBufferAlertMessage: Bool {
        get { fileBuffer?.hasAlertMessage ?? false }
        set { fileBuffer?.hasAlertMessage = newValue }
    }

    func closeFileBuffer() -> Bool {
        guard autoSaveFileBuffer() else { return false }

        LogStore.shared.log("close buffer: \(fileBuffer?.name ?? "nil")")

        fileBuffer?.invalidate()
        fileBuffer = nil
        return true
    }

    func loadFileBuffer() {
        guard closeFileBuffer() else { return }

        let url = selectedFile?.url
        LogStore.shared.log("create buffer: \(url?.lastPathComponent ?? "nil")")

        guard let url else { return }

        let fileBuffer = TextBuffer(from: url)
        fileBuffer.loadOriginalText()
        if !fileBuffer.hasLoadingError {
            addToHistory(url)
        }
        self.fileBuffer = fileBuffer
    }

    func autoSaveFileBuffer() -> Bool {
        guard let fileBuffer else { return true }
        fileBuffer.autoSaveTextView()
        return !fileBuffer.hasAlertMessage
    }

    func saveFileBuffer() {
        guard let fileBuffer else { return }
        fileBuffer.saveTextView()
    }
}
