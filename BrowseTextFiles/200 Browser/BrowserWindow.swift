//
//  BrowserWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct BrowserWindow: Scene {
    @Environment(AppState.self) var appState

    init() {
        printLog("init BrowserWindow")
    }

    var body: some Scene {
        // WindowGroup(... for:) 를 사용해 오픈할 디렉토리 인자를 전달하였더니 BrowserView 가 3번 생성되는 현상이 있다.
        // for: 없는 WindowGroup(...) 을 사용하면 그런 현상이 없다.
        // 먼가 일이 복잡해 지면서 루트 뷰가 여러번 생성되는 것 같다;

        // 오픈할 디렉토리를 for: 로 전달하더라도 디렉토리가 같으면 같은 윈도우로 인식한다.
        // 새로운 윈도우를 만들어주지 않는다.
        // 이걸 해결하려면 UUID 필드를 추가행야 한다.
        // 이것도 좀 문제인 것 같다.

        // 위 현상들을 피하기 위해 for: 인자를 쓰지 말고,
        // 오픈할 디렉토리는 appState 로 전달하는 방식으로 우회하는 것이 안정적일 것 같다;

        // WindowGroup("Browser", id: "browser" , for: BrowserInitParam.self ) { $initParam in
        //     BrowserView(appState: appState, initParam: initParam)
        // }
        // defaultValue: {
        //     BrowserInitParam()
        // }

        //let _ = print("WindowGroup(Browser)")
        WindowGroup("Browser", id: "browser") {
            //let _ = print("--- BrowserView(appState)")
            BrowserView()
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
        .defaultWindowPlacement { proxy, context in
            appState.makeWindowPlacement(
                for: "browser",
                uuid: nil,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 960, height: 600)
            )
        }
        .commands {
            TextEditingCommands()
            BrowserCommands()
        }
    }

}

struct BrowserCommands: Commands {
    @Environment(AppState.self) var appState

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    // @FocusedValue browserState가 struct BrowserWindow 바로 아래 들어있으면 BrowserView 가 두번 생성되었다.
    // @FocusedValue 가 업데이트되면 하위 트리를 모두 새로 만드는 것 같다.
    // 트리 재구성 영역을 줄이기 위해 Commands 코드들을 BrowserCommands struct 로 분리하였다.
    @FocusedValue(BrowserState.self) private var browserState: BrowserState?

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window", systemImage: "macwindow") {
                appState.openNewBrowserWindow(openWindow: openWindow)
            }
            .keyboardShortcut("n", modifiers: [.command, .control])

            Button("New File", systemImage: "text.document") {
                browserState?.makeNewFile()
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button("New File...", systemImage: "text.document") {
                browserState?.showNewFileSheet()
            }
            .keyboardShortcut("n", modifiers: [.command, .option])

            Button("New Folder", systemImage: "folder.badge.plus") {
                browserState?.makeNewFolder()
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Divider()

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
                browserState?.editorState.saveFile()
            }
            .keyboardShortcut("s", modifiers: .command)
        }

        CommandGroup(after: .toolbar) {
            Button("Reload", systemImage: "arrow.clockwise") {
                browserState?.reloadAll()
            }
            .keyboardShortcut("r", modifiers: .command)

            Button("Toggle History", systemImage: "clock") {
                guard let browserState else { return }
                appState.toggleHistoryWindow(for: browserState, openWindow: openWindow, dismissWindow: dismissWindow)
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

        CommandGroup(after: .textEditing) {
            Divider()
            Button("Find in Files", systemImage: "magnifyingglass") {
                guard let browserState else { return }
                appState.openSearchWindow(for: browserState, openWindow: openWindow)
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }
}
