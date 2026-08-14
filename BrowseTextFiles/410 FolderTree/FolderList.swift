//
//  FolderList.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct FolderList: View {
    @Environment(BrowserState.self) var browser

    var body: some View {
        @Bindable var context = browser.context
        @Bindable var folderList = browser.folderList
        List(selection: $context.selectedFolderURLs) {
            if let rootFolder = folderList.rootFolder {
                TreeRow(rootFolder, children: \.children, expanded: $folderList.expandedFolderURLs) { folder in
                    Text(folder.name)
                        .id(folder.id)
                }
            }
        }
        .id(folderList.refreshCount)
    }
}
