//
//  FileBuffer.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers
import MyLibrary

@Observable
final class FileBuffer: Identifiable, Hashable {
    let id = UUID()

    private(set) var rootURL: URL
    private(set) var url: URL
    private(set) var name: String

    private(set) var originalText: String = ""
    var shouldTextViewCopyOriginalText = false

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

    private(set) var alertMessage: String?
    var hasAlertMessage: Bool = false

    private let log = LogStore.shared.log

    init(from url: URL, rootURL: URL) {
        self.rootURL = rootURL
        self.url = url
        self.name = url.lastPathComponent
    }

    var hasLoadingError: Bool {
        loadingError != nil
    }

    var hasSavingError: Bool {
        savingError != nil
    }

    // 애초에 수작업 invalidate 필요없게 만들자.
    // func invalidate() {
    //     fileMonitor = nil
    //     autoSaveTask?.cancel()
    // }

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
        autoSaveTask?.cancel()
        do {
            try withSecurityScope(rootURL) {
                originalText = try String(contentsOf: url, encoding: .utf8)
                startFileMonitoring()
            }
            loadingError = nil
            shouldTextViewCopyOriginalText = true
            log("load text: \(name)")
        } catch {
            let message = error.localizedDescription
            loadingError = message
            log("load text: \(message)")
        }
    }

    private func startFileMonitoring() {
        fileMonitor = FileMonitor()
        fileMonitor!.startMonitoring(url) { [weak self] _ in
            guard let self else { return }
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
            if Task.isCancelled { return }

            guard let self else { return }
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
        print("a")
        guard !hasLoadingError else { return }
        print("b")

        print("\(textView?.string.count ?? -1)")
        guard let text = textView?.string else { return }
        print("c")
        guard let data = text.data(using: .utf8) else { return }
        print("d")

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
            log("save text: \(name)")
        } catch {
            let message = error.localizedDescription
            savingError = message

            alertMessage = message
            hasAlertMessage = true
            log("save text: \(message)")
        }
    }

    func updateTextViewStyle(appState: AppState) {
        guard let textView else { return }

        guard let font = NSFont(name: appState.fontName, size: appState.fontSize) else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = appState.lineSpacing
        // paragraphStyle.lineHeightMultiple = appState.lineHeight

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        textView.typingAttributes = attributes

        guard let storage = textView.textStorage else { return }
        let range = NSRange(
            location: 0,
            length: storage.length
            // length: textView.string.utf16.count
        )
        storage.beginEditing()
        storage.setAttributes(attributes, range: range)
        storage.endEditing()
    }

    static func == (lhs: FileBuffer, rhs: FileBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
