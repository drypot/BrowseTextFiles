//
//  RenameFolderSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/16/26.
//

import SwiftUI

struct RenameFolderSheet: View {
    @Environment(RootState.self) var rootState

    @Environment(\.dismiss) private var dismiss

    @State private var orgName = ""
    @State private var newName = ""
    @State private var selection: TextSelection?
    @FocusState private var isFocused: Bool

    var body: some View {
        Form {
            LabeledContent("Rename Folder") {
                Text(orgName)
            }

            TextField("to", text: $newName, selection: $selection)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
                .focused($isFocused)
                .onChange(of: isFocused) { _, isFocused in
                    if isFocused {
                        selection = TextKitUtil.makeFileNameSelection(from: newName)
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
        guard let name = rootState.renameFolderContext?.oldURL.lastPathComponent else { return }
        orgName = name
        newName = name
    }

    func submit() {
        rootState.renameFolderSubmitted(with: newName)
    }
}
