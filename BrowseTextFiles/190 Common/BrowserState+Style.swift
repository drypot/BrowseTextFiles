//
//  BrowserState+Style.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/29/26.
//

import SwiftUI

final class Styler {

    static let shared = Styler()

    private init() {}

    func foregroundStyleWhen(selected: Bool, active: Bool) -> Color {
        if selected {
            if active {
                Color(nsColor: .selectedMenuItemTextColor)
            } else {
                Color(nsColor: .secondaryLabelColor)
            }
        } else {
            Color(nsColor: .secondaryLabelColor)
        }
    }

    func backgroundStyleWhen(selected: Bool, active: Bool) -> Color {
        if selected {
            if active {
                Color(nsColor: .selectedContentBackgroundColor)
            } else {
                Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
            }
        } else {
            Color(nsColor: .clear)
        }
    }

    func updateTextViewStyle(_ textView: NSTextView?, _ appState: AppState) {
        guard let textView else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        // lineSpacing 쓰면 엔터 입력시 커서가 사라진다; macOS 26
        // paragraphStyle.lineSpacing = appState.lineSpacing
        paragraphStyle.lineHeightMultiple = appState.lineHeightMultiple

        let attributes: [NSAttributedString.Key: Any] = [
            .font: appState.makeNSFontForText(),
            .paragraphStyle: paragraphStyle
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
