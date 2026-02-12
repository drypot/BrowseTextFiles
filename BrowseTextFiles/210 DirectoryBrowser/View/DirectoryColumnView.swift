//
//  DirectoryColumnView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI

struct DirectoryColumnView: View {
    @Environment(DirectoryBrowserModel.self) private var browser

    let column: DirectoryBrowserModel.Column

    @State private var items: [URL] = []
    @State private var selectedItem: URL? = nil

    var body: some View {
        //let _ = print("ColumnView: \(column.id) \(column.index) \(column.directoryURL.lastPathComponent)")
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
            .onChange(of: selectedItem) { x, url in
                Task {
                    browser.didTap(url!, at: column.index)
                }
            }
        }
    }

    private func loadItems() {
        do {
            let raw = try FileManager.default.contentsOfDirectory(
                at: column.directoryURL,
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
