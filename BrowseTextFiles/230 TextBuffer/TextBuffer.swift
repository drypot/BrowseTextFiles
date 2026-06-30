//
//  TextBuffer.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

@Observable
final class TextBuffer {
    private(set) var url: URL
    private(set) var name: String

    private(set) var originalText: String = ""
    var shouldTextViewCopyOriginalText = false

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

    private(set) var loadingError: String?
    private(set) var savingError: String?

    private(set) var alertMessage: String = ""
    var hasAlertMessage: Bool = false

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    var hasLoadingError: Bool {
        loadingError != nil
    }

    var hasSavingError: Bool {
        savingError != nil
    }

    func showAlert(_ message: String) {
        alertMessage = message
        hasAlertMessage = true
    }

    // 애초에 수작업 invalidate 필요없게 만든다고 신경은 썼는네,
    // 혹시나 모르니 확실히 하자.
    func invalidate() {
        fileMonitor = nil
        textView = nil
        autoSaveTask?.cancel()
    }

//    func textBinding() -> Binding<String> {
//        Binding<String>(
//            get: { self.text },
//            set: {
//                self.text = $0
//                self.isEdited = true
//            }
//        )
//    }

    func loadOriginalText() {
        LogStore.shared.log("load: \(name)")
        do {
            originalText = try String(contentsOf: url, encoding: .utf8)
            startFileMonitoring()
            loadingError = nil
            shouldTextViewCopyOriginalText = true
        } catch {
            let message = error.localizedDescription
            loadingError = message
            LogStore.shared.log("load: \(message)")
        }
    }

    private func startFileMonitoring() {
        fileMonitor = FileMonitor()
        fileMonitor!.startMonitoring(url) { [weak self] _ in
            guard let self else { return }
            self.autoSaveTask?.cancel()
            self.loadOriginalText()
            if hasLoadingError {
                fileMonitor = nil
            }
        }
    }

    func scheduleAutoSave(after seconds: Int) {
        guard seconds > 0 else { return }
        autoSaveTask?.cancel()
        autoSaveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard let self else { return }
            guard !Task.isCancelled else { return }
            self.autoSaveTextView()
        }
    }

    func autoSaveTextView() {
        guard isTextViewEdited else { return }
        guard !hasLoadingError else { return }
        guard !hasSavingError else { return }
        saveTextView()
    }

    func saveTextView() {
        guard !hasLoadingError else { return }
        guard let text = textView?.string else { return }
        guard let data = text.data(using: .utf8) else { return }

        LogStore.shared.log("save: \(name)")
        do {
            // 이렇게 하면 먼저 붙였던 fileMonitor 가 떨어져 나간다. 하지 말 것.
            // try text.write(to: url, atomically: true, encoding: .utf8)

            fileMonitor?.ignoreEvent = true
            defer {
                fileMonitor?.ignoreEvent = false
            }

            let fileHandle = try FileHandle(forWritingTo: url)
            try fileHandle.truncate(atOffset: 0)
            try fileHandle.write(contentsOf: data)
            try fileHandle.close()
            savingError = nil
            isTextViewEdited = false
        } catch {
            let message = error.localizedDescription
            savingError = message
            showAlert(message)
            LogStore.shared.log("save: \(message)")
        }
    }
}
