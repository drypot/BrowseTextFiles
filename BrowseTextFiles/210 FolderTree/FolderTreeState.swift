//
//  FolderTreeState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/7/26.
//

import SwiftUI

@Observable
final class FolderTreeState {
    private(set) var rootFolder: FolderState?

    var selectedFolderIDs: Set<FolderState.ID> = []

    var selectedFolderID: FolderState.ID? {
        guard selectedFolderIDs.count == 1 else { return nil }
        return selectedFolderIDs.first
    }

    var expandedFolderIDs: Set<FolderState.ID> = []

    private(set) var rootFolderRefreshCount = 0

    @ObservationIgnored private var rootState: RootState
    @ObservationIgnored private var alertState: AlertState

    init(rootState: RootState, alertState: AlertState) {
        self.rootState = rootState
        self.alertState = alertState
    }

    // MARK: - Folder Tree

    func loadFolderTree(preserveSelection: Bool = true) {
        guard let rootURL = rootState.rootURL else { return }

        consoleLog("load folder tree: \(rootState.rootPath ?? "nil")")
        rootFolder = nil
        do {
            rootFolder = try FolderState.buildTree(from: rootURL)
            rootFolderRefreshCount += 1
            guard let rootFolder else { return }
            if !preserveSelection {
                selectFolder(rootURL)
                expand(rootFolder)
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("load tree: \(message)")
        }
    }

    // MARK: - Selected Folder

    func selectFolder(_ id: FolderState.ID?) {
        if let id {
            selectedFolderIDs = [id]
        } else {
            deselectFolder()
        }
    }

    func deselectFolder() {
        selectedFolderIDs.removeAll()
    }

    /*
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
    */

    // MARK: - Folder Folding

    func expandFolders(for url: URL) {
        guard let rootCount = rootState.rootPathComponents?.count else { return }
        let urlCount = url.pathComponents.count
        var count = urlCount - rootCount

        var tmpURL = url
        while count > 0 {

            print("+ \(tmpURL.path)")

            expandedFolderIDs.insert(tmpURL)
            tmpURL.deleteLastPathComponent()
            count -= 1
        }
    }

    /*
    func isExpanded(_ id: FolderState.ID) -> Bool {
        expandedFolderIDs.contains(id)
    }

    func expand(_ id: FolderState.ID) {
        expandedFolderIDs.insert(id)
    }

    func collapse(_ id: FolderState.ID) {
        expandedFolderIDs.remove(id)
    }

    func toggleExpanded(_ id: FolderState.ID) {
        if isExpanded(id) {
            collapse(id)
        } else {
            expand(id)
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
    */

    // MARK: - New Folder

    func makeNewFolder() {
        guard let selectedFolderID else { return }
        makeNewFolder(in: selectedFolderID)

    }

    func makeNewFolder(in folderURL: URL) {
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
            loadFolderTree(preserveSelection: false)
            expandFolders(for: newFolderURL)
            selectFolder(newFolderURL)
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("new file: \(message)")
        }
    }

    // MARK: - Delete Folder

    func trashFolders(selection: Set<FileState.ID>) {
        selectedFolderIDs.subtract(selection)
        rootFolder?.removeAll(where: { selection.contains($0.id) })
        do {
            let fileManager = FileManager.default
            for url in selection {
                consoleLog("delete folder: \(url.path(percentEncoded: false))")
                try fileManager.trashItem(at: url, resultingItemURL: nil)
            }
        } catch {
            let message = error.localizedDescription
            alertState.showAlert(message)
            consoleLog("delete folder: \(message)")
        }
    }

    // MARK: - Finder

    func openFinder() {
        if let url = selectedFolderID {
            Finder.shared.open(url: url)
        }
    }

}
