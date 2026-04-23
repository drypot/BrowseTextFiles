//
//  FolderTree.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/22/26.
//

import SwiftUI
import MyLibrary

@Observable
final class FolderTree {
    private(set) var rootFolder: Folder?
    public var selectedFolder: Folder?

    var isReady: Bool {
        rootFolder != nil
    }

    var rootURL: URL? {
        rootFolder?.url
    }

    func reset() {
        rootFolder = nil
        selectedFolder = nil
    }

    func loadFolderTree(from rootURL: URL) throws {
        reset()
        rootFolder = try FolderTreeBuilder().build(from: rootURL)
    }

    func reloadTree() throws {
        if let rootURL {
            try loadFolderTree(from: rootURL)
        } else {
            reset()
        }
    }

    func findFolder(with url: URL) -> Folder? {
        rootFolder?.findChild(with: url)
    }
}
