//
//  EditorStyle.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/13/26.
//

import SwiftUI

struct EditorStyle: ViewModifier {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    // TextViewRepresentable.updateNSView 에서 스타일까지 업데이트하면 비효율이 심해진다.
    // 여기로 따로 빼놨다.

    func body(content: Content) -> some View {
        content
            .onChange(of: browser.editor.updateTextViewStyleCount, initial: true) {
                // 새 파일 로드하면 가끔 스타일이 입혀지지 않아서;
                // 로드된 후 스타일을 강제로 한번 입히는 것으로;
                updateTextViewStyle()
            }
            .onChange(of: app.fontName) {
                updateTextViewStyle()
            }
            .onChange(of: app.fontSize) {
                updateTextViewStyle()
            }
            .onChange(of: app.lineSpacing) {
                updateTextViewStyle()
            }
    }

    func updateTextViewStyle() {
        guard let textView = browser.editor.textView else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        // lineSpacing 쓰면 엔터 입력시 커서가 사라진다; macOS 26
        // paragraphStyle.lineSpacing = app.lineSpacing
        paragraphStyle.lineHeightMultiple = app.lineHeightMultiple

        let attributes: [NSAttributedString.Key: Any] = [
            .font: app.makeNSFont(),
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
