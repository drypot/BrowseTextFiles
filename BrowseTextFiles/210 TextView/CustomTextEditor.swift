//
//  CustomTextEditor.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/26/25.
//


import SwiftUI

struct CustomTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Environment(SettingsModel.self) var settings

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView(frame: .zero)

        textView.delegate = context.coordinator

        textView.isEditable = true
        textView.isRichText = false
        textView.isSelectable = true

        // maxSize 설정하고, isVerticallyResizable = true 해야 세로스크롤 할 수 있었다.
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width, .height]

        textView.isHorizontallyResizable = false  // wrap 하려면 false
        textView.textContainer?.widthTracksTextView = true  // wrap 하려면 true

        let attrs = makeAttrs()

        textView.typingAttributes = attrs
        textView.backgroundColor = .textBackgroundColor

        updateTextViewString(textView)

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let textView = nsView.documentView as? NSTextView {
            updateTextViewString(textView)
        }
    }

    func makeAttrs() -> [NSAttributedString.Key: Any] {
        let defautFont = NSFont.systemFont(ofSize: settings.fontSize)
        let font = NSFont(name: settings.fontName, size: settings.fontSize) ?? defautFont

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = settings.lineSpacing

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        return attrs
    }

    func updateTextViewString(_ textView: NSTextView) {
        let attrs = makeAttrs()
        let attrString = NSAttributedString(string: text, attributes: attrs)
        textView.textStorage?.setAttributedString(attrString)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: NSTextView) {
            self.parent.text = textView.string
        }
    }
}
