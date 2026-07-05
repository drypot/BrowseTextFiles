//
//  BrowserState+FolderTree.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {
    // MARK: - Folder Tree

    func loadFolderTree(preserveSelection: Bool = true) {
        consoleLog("load tree: \(rootURL?.path(percentEncoded: false) ?? "nil")")

        guard let rootURL else { return }

        let selectedFolderURL = selectedFolder?.url

        rootFolder = nil
        selectedFolderID = nil
        selectedFolder = nil

        do {
            let folder = try FolderState.buildTree(from: rootURL)
            rootFolder = folder
            selectFolder(folder)
            expand(folder)
            rootFolderRefreshID = UUID()
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("load tree: \(message)")
        }

        if preserveSelection, let selectedFolderURL {
            selectFolder(with: selectedFolderURL)
        }
    }

    func openFinder() {
        if let url = selectedFolder?.url {
            Finder.shared.open(url: url)
        }
    }

    // MARK: - Selected Folder

    func findFolder(with id: FolderState.ID) -> FolderState? {
        guard let rootFolder else { return nil }
        return rootFolder.findFolder(with: id)
    }

    // URL 로 비교하면 패스 마지막에 "/" 이 붙으면서 비교가 귀찮아진다.
    // path 로 비교하면 마지막에 "/" 이 붙지 않는다;
    func findFolder(with path: String) -> FolderState? {
        guard let rootFolder else { return nil }
        return rootFolder.findFolder(with: path)
    }

    func deselectFolder() {
        selectedFolderID = nil
        selectedFolder = nil
    }

    func selectFolder(_ folder: FolderState?) {
        if let folder {
            selectedFolderID = folder.id
            selectedFolder = folder
        } else {
            deselectFolder()
        }
    }

    func selectFolder(with id: FolderState.ID?) {
        if let id, let folder = findFolder(with: id) {
            selectFolder(folder)
        } else {
            deselectFolder()
        }
    }

    func selectFolder(with url: URL) {
        if let folder = findFolder(with: url.path) {
            selectFolder(folder)
        } else {
            deselectFolder()
        }
    }

    func selectNextFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }
        var previous: FolderState?

        func findNext(from current: FolderState) -> FolderState? {
            if previous?.id == selectedFolderID {
                return current
            }
            previous = current

            if let children = current.children, isExpanded(current) {
                for child in children {
                    if let result = findNext(from: child) {
                        return result
                    }
                }
            }

            return nil
        }

        guard let found = findNext(from: rootFolder) else { return false }
        selectFolder(found)
        return true
    }

    func selectPreviousFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }
        var previous: FolderState?

        func findPrevious(from current: FolderState) -> FolderState? {
            if current.id == selectedFolderID {
                return previous
            }
            previous = current

            if let children = current.children, isExpanded(current) {
                for child in children {
                    if let result = findPrevious(from: child) {
                        return result
                    }
                }
            }

            return nil
        }

        guard let found = findPrevious(from: rootFolder) else { return false }
        selectFolder(found)
        return true
    }

    func selectParentFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }

        func findParent(from current: FolderState, parent: FolderState?) -> FolderState? {
            if current.id == selectedFolderID {
                return parent
            }

            if let children = current.children, isExpanded(current) {
                for child in children {
                    if let result = findParent(from: child, parent: current) {
                        return result
                    }
                }
            }

            return nil
        }

        guard let found = findParent(from: rootFolder, parent: nil) else { return false }
        selectFolder(found)
        return true
    }

    // MARK: - Folder Folding

    func isExpanded(_ folder: FolderState) -> Bool {
        expandedFolderIDs.contains(folder.id)
    }

    func expand(_ folder: FolderState) {
        expandedFolderIDs.insert(folder.id)
    }

    func collapse(_ folder: FolderState) {
        expandedFolderIDs.remove(folder.id)
    }

    func toggleExpanded(_ folder: FolderState) {
        if isExpanded(folder) {
            collapse(folder)
        } else {
            expand(folder)
        }
    }

    func expandSelectedFolder() {
        guard let selectedFolder else { return }
        if selectedFolder.hasChildren {
            expand(selectedFolder)
        }
    }

    func collapseSelectedFolder() -> Bool {
        guard let selectedFolder else { return false }
        if selectedFolder.hasChildren, isExpanded(selectedFolder) {
            collapse(selectedFolder)
        } else {
            return selectParentFolder()
        }
        return false
    }

    func expandFolders(for url: URL) {
        guard let rootURL else { return }
        let rootCount = rootURL.pathComponents.count
        let urlCount = url.pathComponents.count
        let count = urlCount - rootCount

        var tmpURL = url
        for _ in 0 ..< count {
            expandedFolderIDs.insert(tmpURL)
            tmpURL = tmpURL.deletingLastPathComponent()
        }
    }
}
