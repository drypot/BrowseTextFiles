//
//  EditorFocus.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct EditorFocus: ViewModifier {
    @Environment(EditorState.self) var editorState
    
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .onChange(of: editorState.shouldFocusedCount) {
                isFocused = true
            }
    }
}

