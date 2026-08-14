//
//  EditorFocus.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct EditorFocus: ViewModifier {
    @Environment(BrowserState.self) var browser

    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .onChange(of: browser.editor.shouldFocusedCount) {
                isFocused = true
            }
    }
}

