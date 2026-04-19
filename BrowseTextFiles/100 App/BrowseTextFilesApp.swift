//
//  BrowseTextFilesApp.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

@main
struct BrowseTextFilesApp: App {
    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.selectedBrowserStatus) var selectedBrowserStatus: TextBrowserStatus?

    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("Browser", id: "browser", for: TextBrowser.InitParam.self) { $initParam in
            TextBrowser(initParam)
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 빈 화면에서 drag & drop 받기 위해
                .environment(settings)

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
                Button("New File") {
                    selectedBrowserStatus?.showNewFileForm()
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("New Tab") {
                    newTab()
                }
                .keyboardShortcut("t", modifiers: .command)

                Button("Open Folder...") {
                    openFolder()
                }
                .keyboardShortcut("o", modifiers: .command)

                Menu("Open Recent") {
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

                Button("Save") {
                    selectedBrowserStatus?.saveFile()
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            CommandGroup(after: .toolbar) {
                Button("Reload") {
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

        }
        .defaultWindowPlacement { proxy, context in
            let displayBounds = context.defaultDisplay.visibleRect
            let size = CGSize(width: displayBounds.width * 2 / 4, height: displayBounds.height * 2 / 3)

            let position = CGPoint(
                x: displayBounds.midX - (size.width / 2),
                y: displayBounds.maxY - size.height - 140)
            return WindowPlacement(position, size: size)
        }

        ConsoneWindow()
        AboutWindow()

        Settings {
            SettingsView()
                .environment(settings)
        }
    }

    func newTab() {
        if let status = selectedBrowserStatus {
            let initParam = TextBrowser.InitParam(rootURL: status.rootURL, fileURL: status.selectedFileURL)
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
                let initParam = TextBrowser.InitParam(rootURL: url)
                openWindow(id: "browser", value: initParam)
            }
        }
    }

    func openRecent(_ url: URL) {
        let initParam = TextBrowser.InitParam(rootURL: url)
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
    @Entry var selectedBrowserStatus: TextBrowserStatus? = nil
}
