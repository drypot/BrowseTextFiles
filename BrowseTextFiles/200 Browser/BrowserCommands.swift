//
//  BrowserCommands.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserCommands: Commands {
    @Environment(AppState.self) var appState

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    // @FocusedValue stateRoot가 struct BrowserWindow 바로 아래 들어있으면 BrowserView 가 두번 생성되었다.
    // @FocusedValue 가 업데이트되면 하위 트리를 모두 새로 만드는 것 같다.
    // 트리 재구성 영역을 줄이기 위해 Commands 코드들을 BrowserCommands struct 로 분리하였다.
    @FocusedValue(BrowserStateRoot.self) private var stateRoot: BrowserStateRoot?

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window", systemImage: "macwindow") {
                appState.openNewBrowserWindow(openWindow: openWindow)
            }
            .keyboardShortcut("n", modifiers: [.command, .control])

            Button("New File", systemImage: "text.document") {
                stateRoot?.makeNewFile()
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button("New File...", systemImage: "text.document") {
                stateRoot?.showNewFileWithTemplate()
            }
            .keyboardShortcut("n", modifiers: [.command, .option])

            Button("New Folder", systemImage: "folder.badge.plus") {
                stateRoot?.makeNewFolder()
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Divider()

            Button("Open Folder...", systemImage: "folder") {
                appState.openNewBrowserWindowFromDialog(openWindow: openWindow)
            }
            .keyboardShortcut("o")

            Menu("Open Recent", systemImage: "text.below.folder") {
                let urls = appState.recentDocumentURLs
                if urls.isEmpty {
                    Text("No Recent Documents")
                } else {
                    ForEach(urls, id: \.self) { url in
                        Button(url.lastPathComponent) {
                            appState.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
                        }
                    }
                    Divider()
                    Button("Clear Menu") {
                        appState.clearRecentDocuments()
                    }
                }
            }

            Divider()

            Button("Save File", systemImage: "square.and.arrow.down") {
                stateRoot?.editorState.saveFile()
            }
            .keyboardShortcut("s")
        }

        CommandGroup(after: .sidebar) {

            Button("Sidebar Folder") {
                stateRoot?.browserState.sidebarStatus = .folder
            }
            .keyboardShortcut("1")

            Button("Sidebar History") {
                stateRoot?.browserState.sidebarStatus = .history
            }
            .keyboardShortcut("2")

            Button("Sidebar Find") {
                stateRoot?.browserState.sidebarStatus = .find
            }
            .keyboardShortcut("3")

            Divider()

            Button("Reload", systemImage: "arrow.clockwise") {
                stateRoot?.reload()
            }
            .keyboardShortcut("r")

            Divider()

            // Button("Toggle History", systemImage: "clock") {
            //     guard let stateRoot else { return }
            //     appState.toggleHistoryWindow(for: stateRoot, openWindow: openWindow, dismissWindow: dismissWindow)
            // }
            // .keyboardShortcut("y")
        }

        CommandGroup(after: .textEditing) {
            Divider()
            Button("Find in Files", systemImage: "magnifyingglass") {
                stateRoot?.browserState.sidebarStatus = .find
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }
}

