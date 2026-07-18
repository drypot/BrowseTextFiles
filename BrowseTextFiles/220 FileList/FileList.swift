//
//  FileList.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct FileList: View {
    @Environment(BrowserContext.self) var context
    @Environment(FileListState.self) var fileListState

    var body: some View {
        @Bindable var context = context
        List(fileListState.fileList ?? [], selection: $context.selectedFileURLs) { file in
            NavigationLink(file.name, value: file.url)
                .id(file.id)
                .listRowSeparator(.hidden)
        }
        .id(fileListState.refreshCount)
    }
}
