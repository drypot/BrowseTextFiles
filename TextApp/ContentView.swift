//
//  ContentView.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var folderURL: URL?
    @State private var fileURLs: [URL] = []
    @State private var selectedFile: URL?
    @State private var fileContents: String = ""

    var body: some View {
        VStack {
            HStack {
                Button("Select Folder") {
                    selectFolder()
                }
                Text(folderURL?.path ?? "Folder not selected")
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            HStack {
                List(fileURLs, id: \.self, selection: $selectedFile) { url in
                    Text(url.lastPathComponent)
                }
                .frame(width: 200)
                .onChange(of: selectedFile) { oldState, newState in
                    loadFileContents()
                }

                TextEditor(text: $fileContents)
                    .font(.body)
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            folderURL = url
            loadFileList(from: url)
        }
    }

    func loadFileList(from folder: URL) {
        let fileManager = FileManager.default
        let txtFiles = (try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) /* ?
            .filter { $0.pathExtension.lowercased() == "txt" }*/ ?? []

        fileURLs = txtFiles
        selectedFile = nil
        fileContents = ""
    }

    func loadFileContents() {
        guard let url = selectedFile else { return }
        fileContents = (try? String(contentsOf: url, encoding: .utf8)) ?? "Can't read file contents"
    }
}

#Preview {
    ContentView()
}
