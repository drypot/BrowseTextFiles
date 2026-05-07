//
//  FileBrowserWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct FileBrowserWindow: Scene {
    @Environment(\.openWindow) private var openWindow
    @Environment(SettingsData.self) var settings
    @FocusedValue(\.selectedBrowserStatus) var selectedBrowserStatus: FileBrowserStatus?

    var body: some Scene {
        WindowGroup("Browser", id: "browser", for: FileBrowser.InitParam.self) { $initParam in
            FileBrowser(initParam)
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 빈 화면에서 drag & drop 받기 위해
            
            // 외부에서 file url 을 받았을 경우 folder 에 대한 권한이 없어서 원만히 작동하기가 힘들다.
            // finder, drag & drop 연동은 일단 하지 않기로 한다.
            // 오로지 folder 만 open 할 수 있는 것으로.
            
            //.contentShape(Rectangle())
            // .onOpenURL { url in
            //     openURLFromFinder(url)
            // }
            // .dropDestination(for: URL.self) { urls, _ in
            //     openURLsFromDragDrop(urls)
            // }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New File", systemImage: "text.document") {
                    selectedBrowserStatus?.showNewFileView()
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("New Tab", systemImage: "macwindow") {
                    newTab()
                }
                .keyboardShortcut("t", modifiers: .command)
                
                Button("Open Folder...", systemImage: "folder") {
                    openFolder()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Menu("Open Recent", systemImage: "text.below.folder") {
                    let urls = settings.recentDocumentURLs
                    if urls.isEmpty {
                        Text("No Recent Documents")
                    } else {
                        ForEach(urls, id: \.self) { url in
                            Button(url.lastPathComponent) {
                                openRecent(url)
                            }
                        }
                        Divider()
                        Button("Clear Menu") {
                            settings.clearRecentDocuments()
                        }
                    }
                }
                
                Divider()
                
                Button("Save", systemImage: "square.and.arrow.down") {
                    selectedBrowserStatus?.saveFile()
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            
            CommandGroup(after: .toolbar) {
                Button("Reload", systemImage: "arrow.clockwise") {
                    selectedBrowserStatus?.reloadAll()
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Divider()
                
                //                Button("Test SecurityScoped") {
                //                    TestSecurityScopedBookmark().testASS()
                //                }
                //                .keyboardShortcut("t", modifiers: .command)
                //
                //                Button("Test SecurityScoped Bookmark") {
                //                    TestSecurityScopedBookmark().testBookmark()
                //                }
                //                .keyboardShortcut("t", modifiers: [.command, .shift])
                //
                //                Button("Test SecurityScoped Bookmark 2") {
                //                    TestSecurityScopedBookmark().testBookmark2()
                //                }
                //                .keyboardShortcut("t", modifiers: [.command, .shift, .control])
            }
            
            TextEditingCommands()
            
            CommandGroup(after: .textEditing) {
                Divider()
                Button("Find in Files", systemImage: "magnifyingglass") {
                    selectedBrowserStatus?.showSearchView()
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

    func newTab() {
        if let status = selectedBrowserStatus {
            let initParam = FileBrowser.InitParam(rootURL: status.rootURL, fileURL: status.selectedFile?.url)
            openWindow(id: "browser", value: initParam)
        } else {
            openWindow(id: "browser")
        }
    }

    func openFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            if let url = panel.url {
                let initParam = FileBrowser.InitParam(rootURL: url)
                openWindow(id: "browser", value: initParam)
            }
        }
    }

    func openRecent(_ url: URL) {
        let initParam = FileBrowser.InitParam(rootURL: url)
        openWindow(id: "browser", value: initParam)
    }

    //    func openURLFromFinder(_ url: URL) {
    //        openWindow(id: "browser", value: url)
    //    }
    //
    //    func openURLsFromDragDrop(_ urls: [URL]) {
    //        for url in urls {
    //            openWindow(id: "browser", value: url)
    //        }
    //    }
}

extension FocusedValues {
    @Entry var selectedBrowserStatus: FileBrowserStatus? = nil
}
