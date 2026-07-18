//
//  EditorError.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct EditorError: View {
    @Environment(BrowserState.self) var state
    @Environment(EditorState.self) var editorState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(editorState.loadingError ?? "...")
                .textSelection(.enabled)
            // Button("Reload folder tree") {
            //     state.reload()
            // }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
