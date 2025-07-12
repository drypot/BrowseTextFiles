//
//  DirectoryBrowserView.swift
//  TextApp
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
                        DirectoryColumnView(columnIndex: idx)
                            .frame(minWidth: 200 /*, maxWidth: 300*/)
                            .border(Color.gray.opacity(0.3))
                    }
                }
                .padding()
            }
            .frame(minWidth: 400)

            VStack(alignment: .leading) {
                ScrollView {
                    if let file = viewModel.selectedFileURL {
                        let content = (try? String(contentsOf: file, encoding: .utf8)) ?? "File cannot be opened."
                        Text(content)
                            .font(.body)
                            .padding()
                    } else {
                        Text("Select a file.")
                            .italic()
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
            }
            .frame(minWidth: 600)
            .layoutPriority(1)
        }
    }
}
