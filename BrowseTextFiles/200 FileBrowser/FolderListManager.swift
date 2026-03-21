//
//  FolderListManager.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 2/26/26.
//

import Foundation
import MyLibrary

@Observable
class FolderListManager {
    private(set) var root: Folder?
    private(set) var folders: [Folder] = []

    func setRoot(to url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let folder = try FolderTreeBuilder().build(from: url)
            root = folder
            // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
            folders = [folder]
        } catch {
            print("folder list update failed: \(error.localizedDescription)")
        }
    }
}
