//
//  RenameSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/16/26.
//

import SwiftUI

struct RenameSheet: View {
    var appState: AppState
    var state: BrowserState

    @Environment(\.dismiss) private var dismiss

    @State private var orgName = ""
    @State private var newName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Form {
                Section {
                    HStack {
                        Text("Rename")
                            .frame(width: 60, alignment: .leading)
                        Text(orgName)
                    }
                    HStack {
                        Text("to")
                            .frame(width: 60, alignment: .leading)
                        TextField("", text: $newName)
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
        .frame(width: 500)
        .onAppear {
            loadSheet()
        }
    }

    func loadSheet() {
        guard let name = state.renamingURL?.lastPathComponent else { return }
        orgName = name
        newName = name
    }

    func submit() {
        state.renameRenamingURL(with: newName)
    }
}

#Preview {
    // RenameFileSheet()
}
