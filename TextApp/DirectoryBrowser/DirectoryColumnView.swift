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

    private var url: URL { viewModel.columns[columnIndex] }
    private var pinned: Bool { viewModel.pinned[columnIndex] }

    private var pinBinding: Binding<Bool> {
        Binding(
            get: { viewModel.pinned[columnIndex] },
            set: { viewModel.setPin($0, at: columnIndex) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: { viewModel.goBack(at: columnIndex) }) {
                    Image(systemName: "chevron.backward")
                }
                .disabled(url.pathComponents.count <= 1)
                .buttonStyle(.plain)

                Spacer()

                Toggle(isOn: pinBinding) {
                    Image(systemName: pinned ? "pin.fill" : "pin")
                }
                .toggleStyle(.button)
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)

            List(items, id: \.self, selection: $selectedItem) { item in
                HStack {
                    Image(systemName: item.hasDirectoryPath ? "folder" : "doc.text")
                    Text(item.lastPathComponent)
                        .lineLimit(1)
                }
                .listRowSeparator(.hidden)
                .contentShape(Rectangle())
                .onTapGesture { viewModel.didTap(item, at: columnIndex) }
            }
            .listStyle(.plain)
            .onAppear(perform: loadItems)
            .onChange(of: url) { loadItems() }
//            .onChange(of: selectedItem) { oldValue, newValue in
//                viewModel.didTap(newValue, at: columnIndex)
//            }
        }
    }

    private func loadItems() {
        do {
            let raw = try FileManager.default.contentsOfDirectory(
                at: url,
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
