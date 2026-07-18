//
//  BrowserCommands.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserCommands: Commands {
    @Environment(AppState.self) var app

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    // @FocusedValue state가 struct BrowserWindow 바로 아래 들어있으면 BrowserView 가 두번 생성되었다.
    // @FocusedValue 가 업데이트되면 하위 트리를 모두 새로 만드는 것 같다.
    // 트리 재구성 영역을 줄이기 위해 Commands 코드들을 BrowserCommands struct 로 분리하였다.
    @FocusedValue(BrowserState.self) private var browser: BrowserState?

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window", systemImage: "macwindow") {
                app.openNewBrowserWindow(openWindow: openWindow)
            }
            .keyboardShortcut("n", modifiers: [.command, .control])

            Button("New File", systemImage: "text.document") {
                browser?.makeNewFile()
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button("New File...", systemImage: "text.document") {
                browser?.showNewFileWithTemplate()
            }
            .keyboardShortcut("n", modifiers: [.command, .option])

            Button("New Folder", systemImage: "folder.badge.plus") {
                browser?.makeNewFolder()
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Divider()

            Button("Open Folder...", systemImage: "folder") {
                app.openNewBrowserWindowFromDialog(openWindow: openWindow)
            }
            .keyboardShortcut("o")

            Menu("Open Recent", systemImage: "text.below.folder") {
                let urls = app.recentDocumentURLs
                if urls.isEmpty {
                    Text("No Recent Documents")
                } else {
                    ForEach(urls, id: \.self) { url in
                        Button(url.lastPathComponent) {
                            app.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
                        }
                    }
                    Divider()
                    Button("Clear Menu") {
                        app.clearRecentDocuments()
                    }
                }
            }

            Divider()

            Button("Save File", systemImage: "square.and.arrow.down") {
                browser?.editor.saveFile()
            }
            .keyboardShortcut("s")
        }

        CommandGroup(after: .sidebar) {

            Button("Sidebar Folder") {
                browser?.context.sidebarStatus = .folder
            }
            .keyboardShortcut("1")

            Button("Sidebar History") {
                browser?.context.sidebarStatus = .history
            }
            .keyboardShortcut("2")

            Button("Sidebar Find") {
                browser?.context.sidebarStatus = .find
            }
            .keyboardShortcut("3")

            Divider()

            Button("Reload", systemImage: "arrow.clockwise") {
                browser?.reload()
            }
            .keyboardShortcut("r")

            Divider()

            // Button("Toggle History", systemImage: "clock") {
            //     guard let state else { return }
            //     app.toggleHistoryWindow(for: state, openWindow: openWindow, dismissWindow: dismissWindow)
            // }
            // .keyboardShortcut("y")
        }

        CommandGroup(after: .textEditing) {
            Divider()
            Button("Find in Files", systemImage: "magnifyingglass") {
                browser?.context.sidebarStatus = .find
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }
}

