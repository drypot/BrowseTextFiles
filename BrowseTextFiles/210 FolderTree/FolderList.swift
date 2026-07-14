//
//  FolderList.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct FolderList: View {
    @Environment(BrowserState.self) var browserState
    @Environment(FolderListState.self) var folderListState

    var body: some View {
        @Bindable var browserState = browserState
        @Bindable var folderListState = folderListState
        List(selection: $browserState.selectedFolderURLs) {
            if let rootFolder = folderListState.rootFolder {
                TreeRow(rootFolder, children: \.children, expanded: $folderListState.expandedFolderURLs) { folder in
                    Text(folder.name)
                        .id(folder.id)
                }
            }
        }
        .id(folderListState.refreshCount)
    }
}
