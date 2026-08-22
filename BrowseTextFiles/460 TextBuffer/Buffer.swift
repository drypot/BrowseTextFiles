//
//  Buffer.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

protocol Editable {
    func load(contentOf url: URL) throws
    var shouldBeSaved: Bool { get }
    func save(to url: URL) throws
}

@Observable
final class Buffer<Content> where Content: Editable {
    private(set) var fileURL: URL?
    private(set) var filename: String?
    private(set) var filePath: String?

    var fileAssigned: Bool {
        fileURL != nil
    }

    private(set) var loadingError: String?
    private(set) var savingError: String?

    var hasLoadingError: Bool {
        loadingError != nil
    }

    var hasSavingError: Bool {
        savingError != nil
    }

    @ObservationIgnored private var fileMonitor: FileMonitor?
    @ObservationIgnored private var autoSaveTask: Task<Void, Never>?

    private(set) var editable: Content?

    @ObservationIgnored private(set) var context: BrowserContext

    init(context: BrowserContext) {
        self.context = context
    }

    func reset() {
        guard fileAssigned else { return }

        //logger.info("reset buffer:")
        fileURL = nil
        filename = nil
        filePath = nil
        loadingError = nil
        savingError = nil
        fileMonitor = nil
        autoSaveTask?.cancel()

        editable = nil
    }

    func loadFile(at url: URL?, to editable: Content?) {
        guard closeFile() else { return }
        guard let editable else { return }
        reset()
        self.editable = editable
        if let url {
            fileURL = url
            filename = url.lastPathComponent
            filePath = url.path(percentEncoded: false)
            loadFile()
        }
    }

    private func loadFile() {
        guard let fileURL else { return }
        guard let editable else { return }

        logger.info("load file: \(self.filePath ?? "nil")")

        do {
            try editable.load(contentOf: fileURL)
            startFileMonitoring()
            logger.info("----")
        } catch {
            let message = error.localizedDescription
            loadingError = message
            logger.info("load file: \(message)")
        }
    }

    private func startFileMonitoring() {
        guard let fileURL else { return }
        fileMonitor = FileMonitor()
        fileMonitor!.startMonitoring(fileURL) { [weak self] event in
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
        logger.info("close file: \(self.filePath ?? "nil")")
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
        guard !hasLoadingError else { return true }
        guard !hasSavingError else { return true }
        guard editable?.shouldBeSaved == true else { return true }
        saveFile()
        return !context.hasAlertMessage
    }

    func saveFile() {
        guard fileAssigned else { return }
        guard let fileURL else { return }
        guard !hasLoadingError else { return }

        logger.info("save file: \(self.filePath ?? "nil")")
        do {
            fileMonitor?.ignoreNextEvent = true
            try editable?.save(to: fileURL)
            savingError = nil
        } catch {
            let message = error.localizedDescription
            savingError = message
            context.leaveAlert(message)
            logger.info("save file: \(message)")
        }
    }
}
