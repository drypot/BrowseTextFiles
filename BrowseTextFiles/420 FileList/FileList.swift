//
//  FileList.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct FileList: View {
    @Environment(BrowserState.self) var browser

    var body: some View {
        @Bindable var context = browser.context
        List(browser.fileList.fileList ?? [], selection: $context.selectedFileURLs) { file in
            NavigationLink(file.name, value: file.url)
                .id(file.id)
                .listRowSeparator(.hidden)
        }
        .id(browser.fileList.refreshCount)
    }
}
