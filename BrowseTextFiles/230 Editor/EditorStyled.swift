//
//  EditorStyled.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct EditorStyled: View {
    @Environment(AppState.self) var appState
    @Environment(EditorState.self) var editorState

    @FocusState private var isFocused: Bool

    var body: some View {
        // SwiftUI TextEditor source of truth 동기화 비효율이 심해서
        // TextViewRepresentable 를 만들었다. NSTextView.string 을 source 로 쓴다.
        TextViewRepresentable()
        //.frame(maxWidth: .infinity, maxHeight: .infinity)
            .focused($isFocused)
            .onChange(of: editorState.shouldFocusedCount) {
                isFocused = true
            }
        // TextViewRepresentable.updateNSView 에서 스타일까지 업데이트하면 비효율이 심해진다.
        // 여기로 따로 빼놨다.
            .onChange(of: editorState.updateTextViewStyleCount, initial: true) {
                // 새 파일 로드하면 가끔 스타일이 입혀지지 않아서;
                // 로드된 후 스타일을 강제로 한번 입히는 것으로;
                updateTextViewStyle()
            }
            .onChange(of: appState.fontName) {
                updateTextViewStyle()
            }
            .onChange(of: appState.fontSize) {
                updateTextViewStyle()
            }
            .onChange(of: appState.lineSpacing) {
                updateTextViewStyle()
            }

        // .overlay(
        //     Text(debugID.uuidString.prefix(4))
        //         .font(.caption)
        //         .foregroundColor(.red),
        //     alignment: .topTrailing
        // )
    }

    func updateTextViewStyle() {
        guard let textView = editorState.textView else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        // lineSpacing 쓰면 엔터 입력시 커서가 사라진다; macOS 26
        // paragraphStyle.lineSpacing = appState.lineSpacing
        paragraphStyle.lineHeightMultiple = appState.lineHeightMultiple

        let attributes: [NSAttributedString.Key: Any] = [
            .font: appState.makeNSFont(),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: NSColor.textColor, // dark mode 대응
            //.backgroundColor: NSColor.textBackgroundColor // dark mode 대응
        ]

        textView.typingAttributes = attributes

        guard let storage = textView.textStorage else { return }
        let range = NSRange(
            location: 0,
            length: storage.length
            // length: textView.string.utf16.count
        )
        storage.beginEditing()
        storage.setAttributes(attributes, range: range)
        storage.endEditing()
    }
}
