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
                HStack(alignment: .top, spacing: 0) {
                    ForEach(viewModel.directoryURLs.indices, id: \.self) { idx in
                        DirectoryColumnView(columnIndex: idx, directoryURL: viewModel.directoryURLs[idx])
                            .frame(minWidth: 150 /*, maxWidth: 300*/)
                            .border(Color.gray.opacity(0.3))
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
