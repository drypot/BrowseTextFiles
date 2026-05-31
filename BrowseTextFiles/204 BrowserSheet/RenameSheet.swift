//
//  RenameSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/16/26.
//

import SwiftUI

struct RenameSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) private var dismiss

    @State private var orgName = ""
    @State private var newName = ""

    var state: BrowserState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Rename")
                .font(.headline)
                .padding()
            Form {
                Section {
                    HStack {
                        Text("from")
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
        .frame(width: 500, height: 250)
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
