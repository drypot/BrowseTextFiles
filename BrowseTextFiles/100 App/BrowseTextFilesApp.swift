//
//  BrowseTextFilesApp.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

@main
struct BrowseTextFilesApp: App {
    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.selectedBufferManager) var selectedBufferManager: TextBufferManager?

    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("Browser", id: "browser", for: URL.self) { $url in
            TextBrowser(url)
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
                Button("New Tab", systemImage: "plus.square") {
                    newTabFromMenu()
                }
                .keyboardShortcut("t", modifiers: .command)

                Button("Open Folder...", systemImage: "arrow.up.right") {
                    openFolderFromMenu()
                }
                .keyboardShortcut("o", modifiers: .command)

                Menu("Open Recent", systemImage: "clock") {
                    let urls = settings.recentDocumentURLs
                    if urls.isEmpty {
                        Text("No Recent Documents")
                    } else {
                        ForEach(urls, id: \.self) { url in
                            Button(url.lastPathComponent) {
                                openRecentFromMenu(url)
                            }
                        }
                        Divider()
                        Button("Clear Menu") {
                            settings.clearRecentDocuments()
                        }
                    }
                }
            }
            CommandGroup(after: .toolbar) {
                Button("Reload", systemImage: "arrow.clockwise") {
                    selectedBufferManager?.reload()
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

        Window("About", id: "about") {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
            // let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
            VStack(spacing: 32) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                VStack(spacing: 4) {
                    Text("Browse Text Files")
                        .font(.headline)
                    Text("Version " + version)
                }
                VStack(spacing: 4) {
                    Text("Source code")
                    Link("https://github.com/drypot/BrowseTextFiles", destination: URL(string: "https://github.com/drypot/BrowseTextFiles")!)
                }
                VStack(spacing: 4) {
                    Text("Email")
                    Link("drypot@gmail.com", destination: URL(string: "mailto:drypot@gmail.com")!)
                }
                Text("© 2026 Kyuhyun Park")
            }
            .padding(EdgeInsets(top: 48, leading: 24, bottom: 48, trailing: 24))
            .frame(width: 320)
            .containerBackground(.thickMaterial, for: .window)
            .windowMinimizeBehavior(.disabled)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .restorationBehavior(.disabled)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Browse Text Files", systemImage: "info.circle") {
                    openWindow(id: "about")
                }
            }
        }
        
        Settings {
            SettingsView()
                .environment(settings)
        }
    }

    func newTabFromMenu() {
        openWindow(id: "browser")
    }

    func openFolderFromMenu() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            if let url = panel.url {
                openWindow(id: "browser", value: url)
            }
        }
    }

    func openRecentFromMenu(_ url: URL) {
        openWindow(id: "browser", value: url)
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
    @Entry var selectedBufferManager: TextBufferManager? = nil
}
