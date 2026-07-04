//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 6/29/26.
//

import SwiftUI

struct FolderTreeViewV2: View {
    @Environment(\.openWindow) private var openWindow

    var appState: AppState
    @Bindable var browserState: BrowserState

    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $browserState.selectedFolderIDs) {
                if let rootFolder = browserState.rootFolder {
                    TreeRow(rootFolder, children: \.children, expanded: $browserState.expandedFolderIDs) { folder in
                        Text(folder.name)
                            .id(folder.id)
                    }
                }
            }
            .id(browserState.rootFolderRefreshID)
            .onAppear {
                scrollToSelection(proxy)
            }
            .onChange(of: browserState.selectedFolderID) {
                scrollToSelection(proxy)
            }
            .contextMenu(forSelectionType: FolderState.ID.self) {
                contextMenu($0)
            }
            .toolbar {
                ToolbarItem {
                    Button("New Folder", systemImage: "folder.badge.plus") {
                        browserState.makeNewFolder()
                    }
                    .help("New Folder")
                }
            }
        }
    }

    @ViewBuilder
    func contextMenu(_ selection: Set<FolderState.ID>) -> some View {
        if selection.count == 0 {
            let _ = consoleLog("0")
        }

//        if selection.count == 1, let first = selection.first {
//            let _ = print("1")
//            Button("New File") {
//                browserState.makeNewFile()
//            }
//
//            Button("New File...") {
//                browserState.showNewFileSheet()
//            }
//
//            Button("New Folder") {
//                browserState.makeNewFolder()
//            }
//
//            Button("Show in Finder") {
//                if let rootURL = browserState.rootURL {
//                    Finder.shared.open(url: rootURL)
//                }
//            }
//
//            Button("Open in New Window") {
//                if let rootURL = browserState.rootURL {
//                    appState.openNewBrowserWindow(fromRootURL: rootURL, fileURL: nil, openWindow: openWindow)
//                }
//            }
//        }
//        if selection.count > 0 {
//            let _ = print("> 0")
//        }
    }

    func scrollToSelection(_ proxy: ScrollViewProxy) {
        guard let id = browserState.selectedFolderID else { return }
        Task {
            withAnimation {
                proxy.scrollTo(id)
            }
        }
    }
}

