//
//  DirectoryColumnView.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI

struct DirectoryColumnView: View {
    let columnIndex: Int
    @Environment(DirectoryBrowserViewModel.self) private var viewModel
    @State private var items: [URL] = []
    @State private var selectedItem: URL? = nil

    private var directoryURL: URL? {
        guard columnIndex < viewModel.directoryURLs.count else { return nil }
        return viewModel.directoryURLs[columnIndex]
    }

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
            .onChange(of: selectedItem) { oldValue, newValue in
                Task { @MainActor in
                    viewModel.didTap(newValue!, at: columnIndex)
                }
            }
        }
    }

    private func loadItems() {
        do {
            guard let directoryURL else { return }
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
