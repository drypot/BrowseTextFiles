//
//  RenameFileSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/16/26.
//

import SwiftUI

struct RenameFileSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) private var dismiss

    @State private var originalURL: URL?
    @State private var originalFilePath = ""
    @State private var newFilePath = ""

    var state: FileBrowserState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Rename/Move File")
                .font(.headline)
                .padding()
            Form {
                Section {
                    HStack {
                        Text("from")
                            .frame(width: 60, alignment: .leading)
                        Text(originalFilePath)
                    }
                    HStack {
                        Text("to")
                            .frame(width: 60, alignment: .leading)
                        TextField("", text: $newFilePath)
                            .labelsHidden()
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Button("OK") {
                    renameFile()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 700, height: 250)
        .onAppear {
            loadSheet()
        }
    }

    func loadSheet() {
        guard let rootURL = state.rootURL else { return }
        let rootPath = rootURL.path

        let fileItem = state.fileList?.first { $0.id == state.renameFileID }
        guard let fileItem else { return }

        originalURL = fileItem.url
        let originalFilePath = String(fileItem.url.path.dropFirst(rootPath.count + 1))
        self.originalFilePath = originalFilePath

        newFilePath = originalFilePath
    }

    func renameFile() {
        Task {
            //state.makeNewFile(path: newFilePath)
        }
    }
}

#Preview {
    // RenameFileSheet()
}
