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
        get { textBuffer?.hasAlertMessage ?? false }
        set { textBuffer?.hasAlertMessage = newValue }
    }

    func closeFileBuffer() -> Bool {
        guard let textBuffer else { return true }
        guard autoSaveFileBuffer() else { return false }

        LogStore.shared.log("close buffer: \(textBuffer.name)")

        textBuffer.invalidate()
        self.textBuffer = nil
        
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
        self.textBuffer = fileBuffer
    }

    func autoSaveFileBuffer() -> Bool {
        guard let textBuffer else { return true }
        textBuffer.autoSaveTextView()
        return !textBuffer.hasAlertMessage
    }

    func saveFileBuffer() {
        guard let textBuffer else { return }
        textBuffer.saveTextView()
    }
}
