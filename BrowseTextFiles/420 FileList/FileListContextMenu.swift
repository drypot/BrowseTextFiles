//
//  FileListContextMenu.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct FileListContextMenu: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @Environment(\.openWindow) private var openWindow

    var selection: Set<FileState.ID>

    var body: some View {
        Button("New File") {
            browser.showNewFile()
        }

        Button("New File...") {
            browser.showNewFileWithTemplate()
        }

        Button("Show in Finder") {
            let url = selection.first ?? browser.context.selectedFolderURL
            app.openFinder(with: url)
        }

        if selection.count == 1 {
            Button("Open in New Window") {
                let url = selection.first
                app.openNewBrowserWindow(fromFileURL: url, openWindow: openWindow)
            }
        } else {
            Button("Open in New Window") {
                app.openNewBrowserWindow(fromFolderURL: browser.context.selectedFolderURL, fileURL: nil, openWindow: openWindow)
            }
        }

        Divider()

        if selection.count == 1 {
            Button("Rename") {
                browser.showRenameFile(for: selection)
            }
        }

        Button("Delete") {
            browser.fileList.trashFiles(selection: selection)
        }
    }
}
