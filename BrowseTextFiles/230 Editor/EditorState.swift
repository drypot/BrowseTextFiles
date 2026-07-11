//
//  EditorState.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

@Observable
final class EditorState {
    private(set) var editingFileURL: URL?
    private(set) var editingFilename: String?

    var fileAssigned: Bool {
        editingFileURL != nil
    }

    private(set) var originalText: String = ""
    var shouldCopyOriginalText = false
    var updateTextViewStyleCount = 0

    var shouldFocusedCount = 0

    private(set) var loadingError: String?
    private(set) var savingError: String?

    var hasLoadingError: Bool {
        loadingError != nil
    }

    var hasSavingError: Bool {
        savingError != nil
    }

    // Data 에서 NSTextView 링크를 갖는 것이 이상하지만;
    // 효율을 위해 NSTextView.string 을 Source of truth 로 쓴다;
    @ObservationIgnored
    weak var textView: NSTextView?

    @ObservationIgnored
    var isTextViewEdited = false

    @ObservationIgnored
    private var fileMonitor: FileMonitor?

    @ObservationIgnored
    private var autoSaveTask: Task<Void, Never>?

    @ObservationIgnored
    private(set) var alertState: AlertState

    init(alertState: AlertState) {
        self.alertState = alertState
    }

    func reset() {
        guard fileAssigned else { return }

        //consoleLog("reset buffer:")
        editingFileURL = nil
        editingFilename = nil
        originalText = ""
        shouldCopyOriginalText = false
        loadingError = nil
        savingError = nil
        isTextViewEdited = false
        fileMonitor = nil
        autoSaveTask?.cancel()
    }

    func loadFile(at url: URL?) {
        guard closeFile() else { return }
        reset()
        if let url {
            editingFileURL = url
            editingFilename = url.lastPathComponent
            loadFile()
        }
    }

    func loadFile() {
        guard let editingFileURL else { return }

        consoleLog("load file: \(editingFileURL.path(percentEncoded: false))")

        do {
            originalText = try String(contentsOf: editingFileURL, encoding: .utf8)
            shouldCopyOriginalText = true
            startFileMonitoring()
            consoleLog("----")
        } catch {
            let message = error.localizedDescription
            loadingError = message
            consoleLog("load file: \(message)")
        }
    }

    private func startFileMonitoring() {
        guard let editingFileURL else { return }
        fileMonitor = FileMonitor()
        fileMonitor!.startMonitoring(editingFileURL) { [weak self] event in
            guard let self else { return }
            self.autoSaveTask?.cancel()
            self.loadFile()
            if hasLoadingError {
                fileMonitor = nil
            }
        }
    }

    func closeFile() -> Bool {
        guard fileAssigned else { return true }
        guard autoSaveFile() else { return false }
        consoleLog("close file: \(editingFileURL?.path(percentEncoded: false) ?? "")")
        reset()
        return true
    }

    func scheduleAutoSave(after seconds: Int) {
        guard seconds > 0 else { return }
        autoSaveTask?.cancel()
        autoSaveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard let self else { return }
            guard !Task.isCancelled else { return }
            _ = self.autoSaveFile()
        }
    }

    func autoSaveFile() -> Bool {
        guard fileAssigned else { return true }
        guard isTextViewEdited else { return true }
        guard !hasLoadingError else { return true }
        guard !hasSavingError else { return true }
        saveFile()
        return !alertState.hasMessage
    }

    func saveFile() {
        guard fileAssigned else { return }
        guard let editingFileURL else { return }
        guard !hasLoadingError else { return }
        guard let text = textView?.string else { return }
        guard let data = text.data(using: .utf8) else { return }

        consoleLog("save file: \(editingFilename ?? "")")
        do {
            // 이렇게 하면 먼저 붙였던 fileMonitor 가 떨어져 나간다. 하지 말 것.
            // try text.write(to: url, atomically: true, encoding: .utf8)

            fileMonitor?.ignoreEvent = true
            defer {
                fileMonitor?.ignoreEvent = false
            }

            let fileHandle = try FileHandle(forWritingTo: editingFileURL)
            try fileHandle.truncate(atOffset: 0)
            try fileHandle.write(contentsOf: data)
            try fileHandle.close()
            savingError = nil
            isTextViewEdited = false
        } catch {
            let message = error.localizedDescription
            savingError = message
            alertState.leaveAlert(message)
            consoleLog("save file: \(message)")
        }
    }
}
