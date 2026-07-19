//
//  NewFolderSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/19/26.
//

import SwiftUI

struct NewFolderSheet: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @Environment(\.dismiss) private var dismiss

    @State private var newFolderName = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        Form {
            TextField("New Folder", text: $newFolderName)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
                .focused($isFocused)

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
        newFolderName = "NewFolder"
    }

    func submit() {
        browser.newFolderSubmitted(with: newFolderName)
    }
}
