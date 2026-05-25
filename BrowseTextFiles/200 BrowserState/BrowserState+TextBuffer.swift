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

    func resetFileBuffer() {
        guard autoSaveFileBuffer() else { return }
        fileBuffer?.invalidate()
        fileBuffer = nil
        LogStore.shared.log("reset buffer:")
    }

    func updateFileBuffer(from url: URL) {
        guard let rootURL else { return }
        guard autoSaveFileBuffer() else { return }

        fileBuffer = TextBuffer(from: url, rootURL: rootURL)
        guard let fileBuffer else { return }

        LogStore.shared.log("create buffer: \(fileBuffer.name)")
        fileBuffer.loadOriginalText()
        if !fileBuffer.hasLoadingError {
            addToHistory(url)
        }
    }

    func updateFileBufferFromSelectedFile() {
        if let selectedFile {
            updateFileBuffer(from: selectedFile.url)
        } else {
            resetFileBuffer()
        }
    }

    func autoSaveFileBuffer() -> Bool {
        guard let fileBuffer else { return true }
        fileBuffer.autoSaveTextView()
        return !fileBuffer.hasAlertMessage
    }

    func saveFile() {
        guard let fileBuffer else { return }
        fileBuffer.saveTextView()
    }
}
