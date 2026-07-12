//
//  EditorContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct EditorContainer: View {
    @Environment(BrowserState.self) var browserState
    @Environment(EditorState.self) var editorState
    @Environment(HistoryState.self) var historyState

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack {
            if editorState.hasLoadingError {
                EditorError()
            } else if editorState.fileAssigned {
                EditorStyled()
                    .ignoresSafeArea()
            }
        }
        .onChange(of: browserState.selectedFileURL, initial: true) { _, url in
            if let url {
                editorState.loadFile(at: url)
                historyState.addToHistory(url)
            } else {
                editorState.reset()
            }
        }
    }
}
