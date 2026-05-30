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

    var state: BrowserState

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
                    submit()
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
        guard let relativePath = state.workingRelativePath else { return }
        orgRelativePath = relativePath
        newRelativePath = relativePath
    }

    func submit() {
        state.renameWorkingFile(with: newRelativePath)
    }
}

#Preview {
    // RenameFileSheet()
}
