//
//  FolderTreeContextMenu.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct FolderTreeContextMenu: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var browserState
    @Environment(FolderTreeState.self) var folderTreeState

    @Environment(\.openWindow) private var openWindow
    
    var selection: Set<FolderState.ID>

    var body: some View {
        if selection.count == 1 {
            Button("New File") {
                let url = selection.first
                browserState.makeNewFile(in: url)
            }

            Button("New File...") {
                let url = selection.first
                browserState.showNewFileSheet(on: url)
            }

            Button("New Folder") {
                guard let url = selection.first else { return }
                folderTreeState.makeNewFolder(in: url)
            }

            Button("Show in Finder") {
                guard let url = selection.first else { return }
                Finder.shared.open(url: url)
            }

            Button("Open in New Window") {
                guard let url = selection.first else { return }
                appState.openNewBrowserWindow(fromRootURL: url, fileURL: nil, openWindow: openWindow)
            }

            Divider()

            Button("Rename") {
                browserState.showRenameFolderSheet(for: selection)
            }
        }

        Button("Delete") {
            folderTreeState.trashFolders(selection: selection)
        }
    }
}
