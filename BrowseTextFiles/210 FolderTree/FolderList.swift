//
//  FolderList.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct FolderList: View {
    @Environment(BrowserContext.self) var context
    @Environment(FolderListState.self) var folderListState

    var body: some View {
        @Bindable var context = context
        @Bindable var folderListState = folderListState
        List(selection: $context.selectedFolderURLs) {
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
