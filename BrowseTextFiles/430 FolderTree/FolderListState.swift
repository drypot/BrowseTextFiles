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

    @ObservationIgnored private var context: BrowserContext

    init(context: BrowserContext) {
        self.context = context
    }

    // MARK: - Folder Tree

    func reloadFolderTree() {
        guard let rootURL = context.rootURL else { return }
        consoleLog("load folder tree: \(rootURL.path(percentEncoded: false))")
        do {
            rootFolder = try FolderState.buildTree(from: rootURL)
            expandFolder(at: rootURL)
            refreshCount += 1
            context.status = .ready
        } catch {
            let message = error.localizedDescription
            context.leaveAlert(message)
            consoleLog("load tree: \(message)")
        }
    }

    // MARK: - Folder Folding

    func expandFolder(at url: URL) {
        expandedFolderURLs.insert(url)
    }

    func expandFoldersUntilSelectedFolder() {
        guard let rootURL = context.rootURL else { return }
        guard let targetURL = context.selectedFolderURL else { return }
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

    // MARK: - Delete Folder

    func trashFolders(selection: Set<FileState.ID>) {
        let fileManager = FileManager.default
        for url in selection {
            consoleLog("delete folder: \(url.path(percentEncoded: false))")
            // 여러 폴더 삭제하다 보면 부모가 먼저 없어지는 경우도 있어서; 오류들을 무시하기로 한다;
            try? fileManager.trashItem(at: url, resultingItemURL: nil)
        }
        reloadFolderTree()
        if let selectedFolderURL = context.selectedFolderURL {
            if selection.contains(selectedFolderURL) {
                context.selectedFolderURL = nil
            }
        }
    }

}
