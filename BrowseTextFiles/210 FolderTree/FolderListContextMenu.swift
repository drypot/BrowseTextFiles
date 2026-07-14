//
//  FolderListContextMenu.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct FolderListContextMenu: View {
    @Environment(AppState.self) var appState
    @Environment(RootState.self) var rootState
    @Environment(BrowserState.self) var browserState
    @Environment(FolderListState.self) var folderListState

    @Environment(\.openWindow) private var openWindow
    
    var selection: Set<FolderState.ID>

    var body: some View {
        if selection.count == 0 {
            let url = browserState.rootURL

            Button("Show in Finder") {
                appState.openFinder(with: url)
            }

            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
            }
        }
        if selection.count == 1 {
            let url = selection.first

            Button("New File") {
                rootState.makeNewFile(in: url)
            }

            Button("New File...") {
                rootState.showNewFileSheet(on: url)
            }

            Button("New Folder") {
                rootState.makeNewFolder(in: url)
            }

            Button("Show in Finder") {
                appState.openFinder(with: url)
            }

            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
            }

            Divider()

            Button("Rename") {
                rootState.showRenameFolderSheet(for: url)
            }
        }

        if selection.count > 0 {
            Button("Delete") {
                folderListState.trashFolders(selection: selection)
            }
        }
    }
}
