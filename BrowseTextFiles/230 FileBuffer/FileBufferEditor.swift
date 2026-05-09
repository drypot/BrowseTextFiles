//
//  FileBufferEditor.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/26/25.
//


import SwiftUI

struct FileBufferEditor: NSViewRepresentable {
    @Environment(AppState.self) var appState

    let fileBuffer: FileBuffer

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let textView = makeTextView()
        let scrollView = makeScrollView(for: textView)

        // configureForNoWrap(textView, scrollView)
        textView.delegate = context.coordinator

        fileBuffer.textView = textView

        return scrollView
    }

    func makeTextView() -> NSTextView {
        let layoutManager = NSTextLayoutManager()

        let textContainer = NSTextContainer()
        layoutManager.textContainer = textContainer

        let contentStorage = NSTextContentStorage()
        contentStorage.addTextLayoutManager(layoutManager)
        // let textStorage = contentStorage.textStorage!

        let textView = NSTextView(frame: .zero, textContainer: textContainer)

        textView.autoresizingMask = [.width, .height] // 필수다.
        textView.textContainerInset = NSSize(width: 16, height: 0) // 패딩

        textView.isEditable = true
        textView.isSelectable = true

        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true

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

    func makeScrollView(for textView: NSView) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        return scrollView
    }

    func configureForNoWrap(_ textView: NSTextView, _ scrollView: NSScrollView) {
        let textContainer = textView.textContainer!

        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true // **

        textContainer.widthTracksTextView = false

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true // **
    }

    func configureForNoScroller(_ textView: NSTextView) {
        let textContainer = textView.textContainer!

        textView.isVerticallyResizable = false // **
        textView.isHorizontallyResizable = false

        textContainer.widthTracksTextView = false // **
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // LogStore @Observable 이라; 여기서 쓰면 View 삭제될 때 무한 루프 생긴다;
        // let log = LogStore.shared.log

        // print("updateNSView: FileBufferEditor")

        if fileBuffer.shouldTextViewCopyOriginalText {
            guard let textView = nsView.documentView as? NSTextView else { return }
            textView.string = fileBuffer.originalText
            fileBuffer.shouldTextViewCopyOriginalText = false
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        let view: FileBufferEditor

        init(_ view: FileBufferEditor) {
            self.view = view
        }

        func textDidChange(_ notification: Notification) {
            // print("textDidChange: Coordinator")
            // guard let textView = notification.object as? NSTextView else { return }

            let fileBuffer = view.fileBuffer
            let appState = view.appState

            fileBuffer.isTextViewEdited = true
            let seconds = appState.autoSaveAfterSeconds
            if seconds > 0 {
                fileBuffer.scheduleAutoSave(after: seconds)
            }
        }
    }

}
