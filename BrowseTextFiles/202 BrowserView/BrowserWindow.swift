//
//  BrowserWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct BrowserWindow: Scene {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow

    @FocusedValue(\.focusedBrowserState) private var state: BrowserState?

    var body: some Scene {
        WindowGroup("Browser", id: "browser", for: BrowserInitParam.self) { $initParam in
            BrowserView(initParam)
            //BrowserDebuggingView(initParam)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 외부에서 file url 을 받았을 경우 folder 에 대한 권한이 없어서 원만히 작동하기가 힘들다.
            // finder, drag & drop 연동은 일단 하지 않기로 한다.
            // 오로지 folder 만 open 할 수 있는 것으로.
            
            //.contentShape(Rectangle()) // 빈 화면에서 drag & drop 받기 위해
            // .onOpenURL { url in
            //     openURLFromFinder(url)
            // }
            // .dropDestination(for: URL.self) { urls, _ in
            //     openURLsFromDragDrop(urls)
            // }
        } defaultValue: {
            BrowserInitParam()
        }
        .defaultWindowPlacement { proxy, context in
            appState.makeWindowPlacement(
                for: "browser",
                uuid: nil,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 960, height: 600)
            )
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New File", systemImage: "text.document") {
                    state?.makeNewFile()
                }
                .keyboardShortcut("n", modifiers: [.command])

                Button("New File...", systemImage: "text.document") {
                    state?.showNewFileSheet()
                }
                .keyboardShortcut("n", modifiers: [.command, .option])

                Button("New Folder", systemImage: "folder.badge.plus") {
                    state?.makeNewFolder()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])

                //Button("New Window", systemImage: "macwindow") {
                //    appState.openNewBrowserWindow(openWindow: openWindow)
                //}
                //.keyboardShortcut("n", modifiers: [.command, .control])

                Button("Open Folder...", systemImage: "folder") {
                    appState.openNewBrowserWindowFromDialog(openWindow: openWindow)
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Menu("Open Recent", systemImage: "text.below.folder") {
                    let urls = appState.recentDocumentURLs
                    if urls.isEmpty {
                        Text("No Recent Documents")
                    } else {
                        ForEach(urls, id: \.self) { url in
                            Button(url.lastPathComponent) {
                                appState.openNewBrowserWindow(fromRootURL: url, fileURL: nil, openWindow: openWindow)
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
                    state?.saveFileBuffer()
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            
            CommandGroup(after: .toolbar) {
                Button("Reload", systemImage: "arrow.clockwise") {
                     state?.reloadAll()
                }
                .keyboardShortcut("r", modifiers: .command)

                Button("Show History", systemImage: "clock") {
                    guard let state else { return }
                    appState.openHistoryWindow(for: state, openWindow: openWindow)
                }
                .keyboardShortcut("y", modifiers: .command)


                Divider()
                
                // Button("Test SecurityScoped") {
                //     TestSecurityScopedBookmark().testASS()
                // }
                // .keyboardShortcut("t", modifiers: .command)

                // Button("Test SecurityScoped Bookmark") {
                //     TestSecurityScopedBookmark().testBookmark()
                // }
                // .keyboardShortcut("t", modifiers: [.command, .shift])

                // Button("Test SecurityScoped Bookmark 2") {
                //     TestSecurityScopedBookmark().testBookmark2()
                // }
                // .keyboardShortcut("t", modifiers: [.command, .shift, .control])
            }
            
            TextEditingCommands()
            
            CommandGroup(after: .textEditing) {
                Divider()
                Button("Find in Files", systemImage: "magnifyingglass") {
                    guard let state else { return }
                    appState.openSearchWindow(for: state, openWindow: openWindow)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            }
        }
    }
}

