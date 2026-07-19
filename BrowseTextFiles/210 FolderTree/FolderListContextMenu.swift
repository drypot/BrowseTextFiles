//
//  FolderListContextMenu.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct FolderListContextMenu: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @Environment(\.openWindow) private var openWindow
    
    var selection: Set<FolderState.ID>

    var body: some View {
        if selection.count == 0 {
            let url = browser.context.rootURL

            Button("Show in Finder") {
                app.openFinder(with: url)
            }

            Button("Open in New Window") {
                app.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
            }
        }
        if selection.count == 1 {
            let url = selection.first

            Button("New File") {
                browser.showNewFile(on: url)
            }

            Button("New File...") {
                browser.showNewFileWithTemplate(on: url)
            }

            Button("New Folder") {
                browser.showNewFolder(on: url)
            }

            Button("Show in Finder") {
                app.openFinder(with: url)
            }

            Button("Open in New Window") {
                app.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
            }

            Divider()

            Button("Rename") {
                browser.showRenameFolder(for: url)
            }
        }

        if selection.count > 0 {
            Button("Delete") {
                browser.folderList.trashFolders(selection: selection)
            }
        }
    }
}
