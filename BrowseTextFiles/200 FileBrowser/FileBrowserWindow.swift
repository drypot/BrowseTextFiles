//
//  FileBrowserWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct FileBrowserInitParam: Hashable, Codable {
    // 동일 폴더를 두 창에서 열려면 id 로 구분되어야 한다.
    let id: UUID
    let rootURL: URL?
    let fileURL: URL?

    // Codable 해야 해서 init 를 번잡스럽게 만들어 준다.
    init(id: UUID = UUID(), rootURL: URL? = nil, fileURL: URL? = nil) {
        self.id = id
        self.rootURL = rootURL
        self.fileURL = fileURL
    }
}

struct FileBrowserWindow: Scene {
    @Environment(AppState.self) var appState
    @Environment(\.openWindow) private var openWindow

    @FocusedValue(\.currentFileBrowserState) var currentState: FileBrowserState?

    var body: some Scene {
        WindowGroup("Browser", id: "browser", for: FileBrowserInitParam.self) { $initParam in
            FileBrowserView(initParam)
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
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Window", systemImage: "macwindow") {
                    appState.openNewBrowserWindow(openWindow: openWindow)
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("New File", systemImage: "text.document") {
                    currentState?.showNewFileView()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])

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
                                appState.openNewBrowserWindow(from: url, fileURL: nil, openWindow: openWindow)
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
                    currentState?.saveFile()
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            
            CommandGroup(after: .toolbar) {
                Button("Reload", systemImage: "arrow.clockwise") {
                     currentState?.reloadAll()
                }
                .keyboardShortcut("r", modifiers: .command)
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
                    appState.openSearchWindow(for: currentState, openWindow: openWindow)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            }
        }
        .defaultWindowPlacement { proxy, context in
            let displayBounds = context.defaultDisplay.visibleRect
            let size = CGSize(width: displayBounds.width * 2 / 4, height: displayBounds.height * 2 / 3)
            
            let position = CGPoint(
                x: displayBounds.midX - (size.width / 2),
                y: displayBounds.maxY - size.height - 140)
            return WindowPlacement(position, size: size)
        }
    }
}

