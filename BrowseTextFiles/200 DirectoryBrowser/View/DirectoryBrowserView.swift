//
//  DirectoryBrowserView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/7/25.
//

import SwiftUI

struct DirectoryBrowserView: View {
    @Environment(DirectoryBrowserViewModel.self) private var viewModel

    var body: some View {
        HSplitView {
            ScrollView(.horizontal) {
                ScrollViewReader { proxy in
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(viewModel.columns) { column in
                            DirectoryColumnView(column: column)
                                .frame(minWidth: 150 /*, maxWidth: 300*/)
                                .border(Color.gray.opacity(0.3))
                        }
                    }
                    .onChange(of: viewModel.columns) {
                        if let last = viewModel.columns.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .trailing)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 400)

            TextFileView(url: viewModel.selectedFileURL)
                .layoutPriority(1)
        }
        .navigationTitle(viewModel.title)
    }
}
