//
//  FolderListState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/7/26.
//

import SwiftUI

@Observable
final class FolderListState {
    private(set) var rootFolder: FolderState?
    var expandedFolderURLs: Set<URL> = []
    var refreshCount = 0

    @ObservationIgnored private var browserState: BrowserState

    init(browserState: BrowserState) {
        self.browserState = browserState
    }

    // MARK: - Folder Tree

    func reloadFolderTree() {
        guard let rootURL = browserState.rootURL else { return }
        consoleLog("load folder tree: \(rootURL.path(percentEncoded: false))")
        do {
            rootFolder = try FolderState.buildTree(from: rootURL)
            expandFolder(at: rootURL)
            refreshCount += 1
            browserState.status = .ready
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("load tree: \(message)")
        }
    }

    // MARK: - Folder Folding

    func expandFolder(at url: URL) {
        expandedFolderURLs.insert(url)
    }

    func expandFoldersUntilSelectedFolder() {
        guard let rootURL = browserState.rootURL else { return }
        guard let targetURL = browserState.selectedFolderURL else { return }
        let rootCount = rootURL.pathComponents.count
        let targetCount = targetURL.pathComponents.count
        var count = targetCount - rootCount + 1

        var tmpURL = targetURL
        while count > 0 {
            expandedFolderURLs.insert(tmpURL)
            tmpURL.deleteLastPathComponent()
            count -= 1
        }
    }

    // MARK: - New Folder

    func makeNewFolder(in folderURL: URL?) {
        guard let folderURL else { return }
        let fileManager = FileManager.default
        var newFolderURL = folderURL.appending(path: "NewFolder", directoryHint: .isDirectory)
        var counter = 1

        while fileManager.fileExists(atPath: newFolderURL.path(percentEncoded: false)), counter < 100 {
            let newName = "NewFolder \(counter)"
            newFolderURL = folderURL.appending(path: newName, directoryHint: .isDirectory)
            counter += 1
        }

        do {
            consoleLog("new folder: \(newFolderURL.path(percentEncoded: false))")
            try fileManager.createDirectory(at: newFolderURL, withIntermediateDirectories: true, attributes: nil)
            reloadFolderTree()
            browserState.selectedFolderURL = newFolderURL
        } catch {
            let message = error.localizedDescription
            browserState.leaveAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    func makeNewFolder() {
        let folderURL = browserState.selectedFolderURL
        makeNewFolder(in: folderURL)
    }

    // MARK: - Delete Folder

    func trashFolders(selection: Set<FileState.ID>) {
        let fileManager = FileManager.default
        for url in selection {
            consoleLog("delete folder: \(url.path(percentEncoded: false))")
            // 여러 폴더 삭제하다 보면 부모가 먼저 없어지는 경우도 있어서; 오류들을 무시하기로 한다;
            try? fileManager.trashItem(at: url, resultingItemURL: nil)
        }
        reloadFolderTree()
        if let selectedFolderURL = browserState.selectedFolderURL {
            if selection.contains(selectedFolderURL) {
                browserState.selectedFolderURL = nil
            }
        }
    }

}
