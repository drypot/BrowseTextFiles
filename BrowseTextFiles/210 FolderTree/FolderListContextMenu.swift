//
//  FolderListContextMenu.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct FolderListContextMenu: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var state
    @Environment(BrowserContext.self) var context
    @Environment(FolderListState.self) var folderListState

    @Environment(\.openWindow) private var openWindow
    
    var selection: Set<FolderState.ID>

    var body: some View {
        if selection.count == 0 {
            let url = context.rootURL

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
                state.makeNewFile(in: url)
            }

            Button("New File...") {
                state.showNewFileWithTemplate(on: url)
            }

            Button("New Folder") {
                state.makeNewFolder(in: url)
            }

            Button("Show in Finder") {
                appState.openFinder(with: url)
            }

            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
            }

            Divider()

            Button("Rename") {
                state.showRenameFolder(for: url)
            }
        }

        if selection.count > 0 {
            Button("Delete") {
                folderListState.trashFolders(selection: selection)
            }
        }
    }
}
