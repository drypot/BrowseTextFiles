//
//  CustomTextEditor.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/26/25.
//


import SwiftUI

struct CustomTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Environment(AppSettings.self) var settings

    func makeNSView(context: Context) -> NSScrollView {
        let textView = TextViewFactory.makeTextView()
        textView.typingAttributes = makeAttr()
        let scrollView = TextViewFactory.makeScrollView(textView)

//        TextViewFactory.configureForNoWrap(textView, scrollView)
//        textView.delegate = context.coordinator

//        updateTextViewString(textView)

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let textView = nsView.documentView as? NSTextView {
            updateTextViewString(textView)
        }
    }

    func makeAttr() -> [NSAttributedString.Key : Any] {
        let defautFont = NSFont.systemFont(ofSize: settings.fontSize)
        let font = NSFont(name: settings.fontName, size: settings.fontSize) ?? defautFont

        let lineHeightMultiple = 1.7

        let fontHeight = font.ascender + abs(font.descender) // + font.leading
        let lineHeight = fontHeight * lineHeightMultiple
        let baselineOffset = (lineHeight - fontHeight) / 2

        // lineSpacing 을 쓰면 Enter 후 빈줄에서 커서가 커지는 현상이 발생한다.
        // 문자를 입력하면 다시 줄어든다.

        // lineHeightMultiple 을 쓰면 커서가 위로 삐죽이 올라온다.

        // minimumLineHeight 를 주고 baselineOffset 을 조절하는 것이 무난해 보인다.

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.0
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight

        let attr: [NSAttributedString.Key : Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: baselineOffset,
            .foregroundColor: NSColor.textColor,
            .backgroundColor: NSColor.textBackgroundColor,
        ]

        return attr
    }

    func updateTextViewString(_ textView: NSTextView) {
        textView.string = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var view: CustomTextEditor

        init(_ view: CustomTextEditor) {
            self.view = view
        }

        func textViewDidChange(_ textView: NSTextView) {
            self.view.text = textView.string
        }
    }
}
