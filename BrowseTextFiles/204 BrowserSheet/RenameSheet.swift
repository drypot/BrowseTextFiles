//
//  RenameSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/16/26.
//

import SwiftUI

struct RenameSheet: View {
    @Environment(RenameState.self) var renameState

    @Environment(\.dismiss) private var dismiss

    @State private var orgName = ""
    @State private var newName = ""
    @State private var selection: TextSelection?
    @FocusState private var isFocused: Bool

    var body: some View {
        Form {
            LabeledContent("Rename") {
                Text(orgName)
            }

            TextField("to", text: $newName, selection: $selection)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
                .focused($isFocused)
                .onChange(of: isFocused) { _, isFocused in
                    if isFocused {
                        selectNameWithoutExtension()
                    }
                }

            HStack {
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
        }
        .formStyle(.columns)
        .padding()
        .frame(width: 500)
        .task {
            initSheet()
        }
    }

    func initSheet() {
        guard let name = renameState.renamingURL?.lastPathComponent else { return }
        orgName = name
        newName = name
    }

    func selectNameWithoutExtension() {
        if let dotIndex = newName.lastIndex(of: ".") {
            let range = newName.startIndex..<dotIndex
            selection = TextSelection(range: range)
        } else {
            selection = TextSelection(range: newName.startIndex..<newName.endIndex)
        }
    }

    func submit() {
        renameState.rename(with: newName)
    }
}
