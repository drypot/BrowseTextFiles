//
//  FileListContextMenu.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct FileListContextMenu: View {
    @Environment(AppState.self) var appState
    @Environment(RootState.self) var rootState
    @Environment(BrowserState.self) var browserState
    @Environment(FileListState.self) var fileListState

    @Environment(\.openWindow) private var openWindow

    var selection: Set<FileState.ID>

    var body: some View {
        Button("New File") {
            rootState.makeNewFile()
        }

        Button("New File...") {
            rootState.showNewFileWithTemplate()
        }

        Button("Show in Finder") {
            let url = selection.first ?? browserState.selectedFolderURL
            appState.openFinder(with: url)
        }

        if selection.count == 1 {
            Button("Open in New Window") {
                let url = selection.first
                appState.openNewBrowserWindow(fromFileURL: url, openWindow: openWindow)
            }
        } else {
            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFolderURL: browserState.selectedFolderURL, fileURL: nil, openWindow: openWindow)
            }
        }

        Divider()

        if selection.count == 1 {
            Button("Rename") {
                rootState.showRenameFile(for: selection)
            }
        }

        Button("Delete") {
            fileListState.trashFiles(selection: selection)
        }
    }
}
