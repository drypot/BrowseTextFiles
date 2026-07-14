//
//  FolderList.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct FolderList: View {
    @Environment(BrowserState.self) var browserState
    @Environment(FolderListState.self) var folderTreeState

    var body: some View {
        @Bindable var browserState = browserState
        @Bindable var folderTreeState = folderTreeState
        List(selection: $browserState.selectedFolderURLs) {
            if let rootFolder = folderTreeState.rootFolder {
                TreeRow(rootFolder, children: \.children, expanded: $folderTreeState.expandedFolderURLs) { folder in
                    Text(folder.name)
                        .id(folder.id)
                }
            }
        }
        .id(folderTreeState.refreshCount)
    }
}
