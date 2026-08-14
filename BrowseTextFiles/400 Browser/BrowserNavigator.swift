//
//  BrowserNavigator.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/11/26.
//

import SwiftUI

struct BrowserNavigator: View {
    var body: some View {
        NavigationSplitView {
            //FolderListContainer()
            SidebarContainer()
                .frame(minWidth: 200, maxHeight: .infinity)
        } content: {
            FileListContainer()
                .frame(minWidth: 180, maxHeight: .infinity)
        } detail: {
            EditorContainer()
                .frame(minWidth: 300, maxHeight: .infinity)
        }
    }
}

#Preview {
    BrowserNavigator()
}
