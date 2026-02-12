//
//  DirectoryBrowserView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/7/25.
//

import SwiftUI

struct DirectoryBrowserView: View {
    @Environment(DirectoryBrowserModel.self) private var browser

    var body: some View {
        HSplitView {
            ScrollView(.horizontal) {
                ScrollViewReader { proxy in
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(browser.columns) { column in
                            DirectoryColumnView(column: column)
                                .frame(minWidth: 150 /*, maxWidth: 300*/)
                                .border(Color.gray.opacity(0.3))
                        }
                    }
                    .onChange(of: browser.columns) {
                        if let last = browser.columns.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .trailing)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 400)

            TextFileView(url: browser.selectedFileURL)
                .layoutPriority(1)
        }
        .navigationTitle(browser.title)
    }
}
