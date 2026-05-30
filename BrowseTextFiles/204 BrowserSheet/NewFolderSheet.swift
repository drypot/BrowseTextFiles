//
//  NewFolderSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/30/26.
//

import SwiftUI

struct NewFolderSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) private var dismiss

    @State private var newFolderPath = ""

    var state: BrowserState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("New Folder")
                .font(.headline)
                .padding()
            Form {
                Section(header: Text("Relative path from the root")) {
                    TextField("", text: $newFolderPath)
                        .frame(maxWidth: .infinity)
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
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
        .frame(width: 500, height: 200)
        .onAppear {
            loadSheet()
        }
    }

    func loadSheet() {
        newFolderPath = (state.workingRelativePath ?? "") + "/NewFolder"
    }

    func submit() {
        state.makeNewFolder(with: newFolderPath)
    }

}

#Preview {
//    NewFileSheet()
}
