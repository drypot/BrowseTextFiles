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

    @State private var orgURL: URL?
    @State private var orgRelativePath = ""
    @State private var newRelativePath = ""

    var state: FileBrowserState

    private let log = LogStore.shared.log

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
                    renameFile()
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
        let rootPath = rootURL.path

        guard let fileItem = state.findFile(with: state.renameFileID) else { return }

        orgURL = fileItem.url
        let orgRelativePath = String(fileItem.url.path.dropFirst(rootPath.count + 1))
        self.orgRelativePath = orgRelativePath

        newRelativePath = orgRelativePath
    }

    func renameFile() {
        Task {
            guard let rootURL = state.rootURL else { return }
            guard let orgURL else { return }
            let newURL = rootURL.appending(path: newRelativePath)
            state.renameFile(from: orgURL, to: newURL)
        }
    }
}

#Preview {
    // RenameFileSheet()
}
