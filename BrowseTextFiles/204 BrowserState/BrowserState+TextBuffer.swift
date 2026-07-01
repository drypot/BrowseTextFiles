//
//  BrowserState+EditorState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {
    // MARK: - EditorState

    var hasFileBufferAlertMessage: Bool {
        get { editorState?.hasAlertMessage ?? false }
        set { editorState?.hasAlertMessage = newValue }
    }

    func closeFileBuffer() -> Bool {
        guard let editorState else { return true }
        guard autoSaveFileBuffer() else { return false }

        LogStore.shared.log("close buffer: \(editorState.name)")

        editorState.invalidate()
        self.editorState = nil
        
        return true
    }

    func loadFileBuffer() {
        guard closeFileBuffer() else { return }

        let url = selectedFile?.url
        LogStore.shared.log("create buffer: \(url?.lastPathComponent ?? "nil")")

        guard let url else { return }

        let fileBuffer = EditorState(from: url)
        fileBuffer.loadOriginalText()
        if !fileBuffer.hasLoadingError {
            historyState.addToHistory(url)
        }
        self.editorState = fileBuffer
    }

    func autoSaveFileBuffer() -> Bool {
        guard let editorState else { return true }
        editorState.autoSaveTextView()
        return !editorState.hasAlertMessage
    }

    func saveFileBuffer() {
        guard let editorState else { return }
        editorState.saveTextView()
    }
}
