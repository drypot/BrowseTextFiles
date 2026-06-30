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
    @Bindable var state: BrowserState

    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $state.selectedFolderIDs) {
                if let rootFolder = state.rootFolder {
                    TreeRow(rootFolder, children: \.children, expanded: $state.expandedFolderIDs) { folder in
                        Text(folder.name)
                            .id(folder.id)
                    }
                }
            }
            .id(state.rootFolderRefreshID)
            .onAppear {
                scrollToSelection(proxy)
            }
            .onChange(of: state.selectedFolderID) {
                scrollToSelection(proxy)
            }
            .contextMenu(forSelectionType: FolderState.ID.self) {
                contextMenu($0)
            }
            .toolbar {
                ToolbarItem {
                    Button("New Folder", systemImage: "folder.badge.plus") {
                        state.makeNewFolder()
                    }
                    .help("New Folder")
                }
            }
        }
    }

    @ViewBuilder
    func contextMenu(_ selection: Set<FolderState.ID>) -> some View {
        if selection.count == 0 {
            let _ = print("0")
        }

        if selection.count == 1, let first = selection.first {
            let _ = print("1")
            Button("New File") {
                state.makeNewFile()
            }

            Button("New File...") {
                state.showNewFileSheet()
            }

            Button("New Folder") {
                state.makeNewFolder()
            }

            Button("Show in Finder") {
                if let rootURL = state.rootURL {
                    Finder.shared.open(url: rootURL)
                }
            }

            Button("Open in New Window") {
                if let rootURL = state.rootURL {
                    appState.openNewBrowserWindow(fromRootURL: rootURL, fileURL: nil, openWindow: openWindow)
                }
            }
        }
        if selection.count > 0 {
            let _ = print("> 0")
        }
    }

    func scrollToSelection(_ proxy: ScrollViewProxy) {
        guard let id = state.selectedFolderID else { return }
        Task {
            withAnimation {
                proxy.scrollTo(id)
            }
        }
    }
}

