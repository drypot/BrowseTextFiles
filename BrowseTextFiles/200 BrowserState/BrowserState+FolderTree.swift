//
//  BrowserState+FolderTree.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/24/26.
//

import SwiftUI

extension BrowserState {
    // MARK: - Folder Tree

    func updateFolderTree(preserveSelection: Bool = true) {
        guard let rootURL else { return }

        let selectedFolderURL = selectedFolder?.url

        rootFolder = nil
        selectedFolderID = nil
        selectedFolder = nil

        do {
            let folder = try FolderTreeBuilder().buildTree(from: rootURL)
            rootFolder = folder
            selectFolder(folder)
            expandFolder(for: folder.url)
            LogStore.shared.log("load tree: \(rootName ?? "nil")")
        } catch {
            let message = error.localizedDescription
            showAlert(message)
            LogStore.shared.log("load tree: \(message)")
        }

        if preserveSelection, let selectedFolderURL {
            selecteFolder(withURL: selectedFolderURL)
        }
    }

    // MARK: - Selected Folder

    func findFolder(withID id: FolderForView.ID) -> FolderForView? {
        guard let rootFolder else { return nil }
        return rootFolder.findFolder(withID: id)
    }

    // URL 로 비교하면 패스 마지막에 "/" 이 붙으면서 비교가 귀찮아진다.
    // path 로 비교하면 마지막에 "/" 이 붙지 않는다;
    func findFolder(withPath path: String) -> FolderForView? {
        guard let rootFolder else { return nil }
        return rootFolder.findFolder(withPath: path)
    }

    func deselectFolder() {
        selectedFolderID = nil
        selectedFolder = nil
    }

    func selectFolder(_ folder: FolderForView?) {
        if let folder {
            selectedFolderID = folder.id
            selectedFolder = folder
        } else {
            deselectFolder()
        }
    }

    func selecteFolder(withID id: FolderForView.ID?) {
        if let id, let folder = findFolder(withID: id) {
            selectFolder(folder)
        } else {
            deselectFolder()
        }
    }

    func selecteFolder(withURL url: URL) {
        if let folder = findFolder(withPath: url.path) {
            selectFolder(folder)
        } else {
            deselectFolder()
        }
    }

    func selectedRootFolder() {
        selectFolder(rootFolder)
    }

    func selecteNextFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }
        var previous: FolderForView?

        func findNext(from current: FolderForView) -> FolderForView? {
            if previous?.id == selectedFolderID {
                return current
            }
            previous = current

            if let children = current.children, isFolderExpanded(for: current.url) {
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

    func selectePreviousFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }
        var previous: FolderForView?

        func findPrevious(from current: FolderForView) -> FolderForView? {
            if current.id == selectedFolderID {
                return previous
            }
            previous = current

            if let children = current.children, isFolderExpanded(for: current.url) {
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

    func selecteParentFolder() -> Bool {
        guard let rootFolder else { return false }
        guard let selectedFolderID else { return false }

        func findParent(from current: FolderForView, parent: FolderForView?) -> FolderForView? {
            if current.id == selectedFolderID {
                return parent
            }

            if let children = current.children, isFolderExpanded(for: current.url) {
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

    func isFolderExpanded(for url: URL) -> Bool {
        expandedFolders.contains(url)
    }

    func expandFolder(for url: URL) {
        expandedFolders.insert(url)
    }

    func collapseFolder(for url: URL) {
        expandedFolders.remove(url)
    }

    func toggleFolder(for url: URL) {
        if isFolderExpanded(for: url) {
            collapseFolder(for: url)
        } else {
            expandFolder(for: url)
        }
    }

    func expandSelectedFolder() {
        guard let selectedFolder else { return }
        if selectedFolder.hasChildren {
            expandFolder(for: selectedFolder.url)
        }
    }

    func collapseSelectedFolder() -> Bool {
        guard let selectedFolder else { return false }
        if selectedFolder.hasChildren, isFolderExpanded(for: selectedFolder.url) {
            collapseFolder(for: selectedFolder.url)
        } else {
            return selecteParentFolder()
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
            expandFolder(for: tmpURL)
            tmpURL = tmpURL.deletingLastPathComponent()
        }
    }
}
