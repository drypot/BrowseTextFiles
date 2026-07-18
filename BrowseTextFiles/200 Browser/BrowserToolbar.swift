//
//  BrowserToolbar.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/11/26.
//

import SwiftUI

struct BrowserToolbar: ToolbarContent {
    @Environment(AppState.self) var appState
    @Environment(BrowserStateRoot.self) var stateRoot

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some ToolbarContent {
        // ToolbarItemGroup(placement: .navigation) {
        //     Button("Prev", systemImage: "chevron.left")  {
        //     }
        //     .help("이전 항목으로 이동")

        //     Button("Next", systemImage: "chevron.right") {
        //     }
        //     .help("다음 항목으로 이동")
        // }

        ToolbarItemGroup(placement: .navigation) {
            Button("Reload", systemImage: "arrow.clockwise") {
                stateRoot.reload()
            }
            .help("Reload")
        }

        ToolbarItemGroup(placement: .secondaryAction) {
            Button("New File", systemImage: "square.and.pencil") {
                stateRoot.makeNewFile()
            }
            .help("New File")

            Button("New File...", systemImage: "bubble.and.pencil") {
                stateRoot.showNewFileWithTemplate()
            }
            .help("New File...")

            Button("New Folder", systemImage: "folder.badge.plus") {
                stateRoot.makeNewFolder()
            }
            .help("New Folder")

            //Button("Show History", systemImage: "clock") {
            //    appState.toggleHistoryWindow(for: stateRoot, openWindow: openWindow, dismissWindow: dismissWindow)
            //}
            //.help("Show History")
        }

        ToolbarItem(placement: .primaryAction) {
            Button("Search", systemImage: "magnifyingglass") {
                //appState.toggleSearchWindow(for: stateRoot, openWindow: openWindow, dismissWindow: dismissWindow)
                stateRoot.browserState.sidebarStatus = .find
            }
            .help("Search")
        }
    }
}
