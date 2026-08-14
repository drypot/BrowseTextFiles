//
//  NewFileSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/19/26.
//

import SwiftUI

struct NewFileSheet: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @Environment(\.dismiss) private var dismiss

    @State private var newFileName = ""
    @State private var selection: TextSelection?
    @FocusState private var isFocused: Bool

    var body: some View {
        Form {
            TextField("New File:", text: $newFileName, selection: $selection)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
                .focused($isFocused)
                .onChange(of: isFocused) { _, isFocused in
                    if isFocused {
                        selection = TextKitUtil.makeFileNameSelection(from: newFileName)
                    }
                }

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
        }
        .formStyle(.columns)
        .padding()
        .frame(width: 320)
        .task {
            initSheet()
        }
    }

    func initSheet() {
        newFileName = app.newFileName
    }

    func submit() {
        browser.newFileSubmitted(with: newFileName)
    }
}
