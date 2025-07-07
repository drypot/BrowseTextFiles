//
//  DirectoryBrowserView.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/7/25.
//

import SwiftUI

struct DirectoryBrowserView: View {
    let initialURL: URL
    @State private var pathStack: [URL]
    @State private var selectedFile: URL? = nil

    init(initialURL: URL) {
        self.initialURL = initialURL
        _pathStack = State(initialValue: [initialURL])
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(pathStack.enumerated()), id: \.element) { index, url in
                DirectoryListView(pathStackIndex: index, pathStack: $pathStack, selectedFile: $selectedFile)
                    .frame(minWidth: 200, maxWidth: 300)
                    .border(Color.gray.opacity(0.2), width: 1)
            }

            if let fileURL = selectedFile {
                FileTextView(fileURL: fileURL)
                    .id(fileURL.absoluteString)
                    .frame(minWidth: 300)
                    .border(Color.gray.opacity(0.2), width: 1)
            } else {
                Spacer()
            }
        }
        .frame(minWidth: 200, minHeight: 400)
    }
}

struct DirectoryListView: View {
    let pathStackIndex: Int
    @Binding var pathStack: [URL]
    @Binding var selectedFile: URL?

    @State private var items: [URL] = []

    var body: some View {
        List(items, id: \.self) { item in
            let isDir = (try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            HStack {
                Image(systemName: isDir ? "folder" : "doc.text")
                Text(item.lastPathComponent)
                Spacer()
            }
            .contentShape(Rectangle())  // 텍스트 영역 밖도 클릭 가능
            .onTapGesture {
                pathStack = Array(pathStack.prefix(pathStackIndex + 1))
                if isDir {
                    pathStack.append(item)
                    selectedFile = nil
                } else {
                    selectedFile = item
                }
            }
        }
        .listStyle(PlainListStyle())
        .onAppear(perform: loadDirectory)
    }

    private func loadDirectory() {
        let fm = FileManager.default
        let directoryURL = pathStack[pathStackIndex]
        do {
            let urls = try fm.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            items = urls.sorted { a, b in
                let aIsDir = (try? a.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let bIsDir = (try? b.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if aIsDir != bIsDir {
                    return aIsDir && !bIsDir
                }
                return a.lastPathComponent.lowercased() < b.lastPathComponent.lowercased()
            }
        } catch {
            print("Directory loading failed: \(error)")
            items = []
        }
    }

}
