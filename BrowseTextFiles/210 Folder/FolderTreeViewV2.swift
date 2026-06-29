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
//            .onChange(of: state.focusFolderID) {
//                guard let id = state.focusFolderID else { return }
//                proxy.scrollTo(id)
//            }
        }
    }
}

