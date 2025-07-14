//
//  DirectoryColumnView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI

struct DirectoryColumnView: View {
    @Environment(DirectoryBrowserViewModel.self) private var viewModel

    let columnIndex: Int
    let directoryURL: URL

    @State private var items: [URL] = []
    @State private var selectedItem: URL? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List(items, id: \.self, selection: $selectedItem) { item in
                HStack {
                    Image(systemName: item.hasDirectoryPath ? "folder" : "doc.text")
                    Text(item.lastPathComponent)
                        .lineLimit(1)
                }
                .listRowSeparator(.hidden)
                .contentShape(Rectangle())
            }
            .listStyle(.plain)
            .onAppear(perform: loadItems)
            .onChange(of: directoryURL, loadItems)
            .onChange(of: selectedItem) { x, url in
                Task { @MainActor in
                    viewModel.didTap(url!, at: columnIndex)
                }
            }
        }
    }

    private func loadItems() {
        do {
            let raw = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            items = raw.sorted { a, b in
                let aIsDir = (try? a.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let bIsDir = (try? b.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if aIsDir == bIsDir {
                    return a.lastPathComponent.lowercased() < b.lastPathComponent.lowercased()
                }
                return aIsDir && !bIsDir
            }
        } catch {
            items = []
            print("Directory load error:", error)
        }
    }
}
