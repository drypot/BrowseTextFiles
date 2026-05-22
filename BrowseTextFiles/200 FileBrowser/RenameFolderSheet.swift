//
//  RenameFileSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/16/26.
//

import SwiftUI

struct RenameFolderSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) private var dismiss

    @State private var orgURL: URL?
    @State private var orgRelativePath = ""
    @State private var newRelativePath = ""

    var state: FileBrowserState

    private let log = LogStore.shared.log

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Rename/Move Folder")
                .font(.headline)
                .padding()
            Form {
                Section {
                    HStack {
                        Text("from")
                            .frame(width: 60, alignment: .leading)
                        Text(orgRelativePath)
                    }
                    HStack {
                        Text("to")
                            .frame(width: 60, alignment: .leading)
                        TextField("", text: $newRelativePath)
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
                    rename()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 500, height: 250)
        .onAppear {
            loadSheet()
        }
    }

    func loadSheet() {
        guard let rootURL = state.rootURL else { return }
        guard let renameFolderID = state.renameFolderID else { return }
        guard let folder = state.findFolder(withID: renameFolderID) else { return }
        guard let relativePath = folder.url.relativePath(from: rootURL) else { return }
        orgURL = folder.url
        orgRelativePath = relativePath
        newRelativePath = relativePath
    }

    func rename() {
        Task {
            guard let rootURL = state.rootURL else { return }
            guard let orgURL else { return }
            let newURL = rootURL.appending(path: newRelativePath)
            state.renameFolder(from: orgURL, to: newURL)
        }
    }
}

#Preview {
    // RenameFileSheet()
}
