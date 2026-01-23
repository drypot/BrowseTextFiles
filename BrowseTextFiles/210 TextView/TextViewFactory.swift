//
//  TextViewFactory.swift
//  HelloAppKit
//
//  Created by Kyuhyun Park on 8/19/25.
//

import Cocoa

// TextKit
// https://developer.apple.com/documentation/appkit/textkit

// Meet TextKit 2
// https://developer.apple.com/videos/play/wwdc2021/10061/

struct TextViewFactory {

    static func makeTextView() -> NSTextView {
        let layoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer()
        layoutManager.textContainer = textContainer
        let contentStorage = NSTextContentStorage()
        contentStorage.addTextLayoutManager(layoutManager)
//        let textStorage = contentStorage.textStorage!

        let textView = NSTextView(frame: .zero, textContainer: textContainer)

        textView.autoresizingMask = [.width, .height] // 필수다.
        textView.textContainerInset = NSSize(width: 8, height: 8) // 패딩

        textView.isEditable = true
        textView.isSelectable = true

        textView.isRichText = false
        textView.importsGraphics = false

        // 사용자 입력에 따라 컨트롤이 계속 커지게 만들려면 true.
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false // **
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        // Wrap 모드면 true
        textContainer.widthTracksTextView = true // **
        textContainer.size = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        return textView
    }

    static func makeScrollView(_ textView: NSView) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        return scrollView
    }

    static func configureForNoWrap(_ textView: NSTextView, _ scrollView: NSScrollView) {
        let textContainer = textView.textContainer!

        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true // **

        textContainer.widthTracksTextView = false

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true // **
    }

    static func configureForNoScroller(_ textView: NSTextView) {
        let textContainer = textView.textContainer!

        textView.isVerticallyResizable = false // **
        textView.isHorizontallyResizable = false

        textContainer.widthTracksTextView = false // **
    }

}
