//
//  TextBufferEditor.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/26/25.
//


import SwiftUI

// https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextEditing/TextEditing.html#//apple_ref/doc/uid/TP40009459-CH3-SW16

struct TextBufferEditor: NSViewRepresentable {
    @Environment(AppState.self) var appState
    @Environment(FileBrowserState.self) var state

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        //print("nsview created: \(state.id), TextBufferEditor.makeNSView")

        let textView = makeTextView()
        let scrollView = makeScrollView(for: textView)

        // configureForNoWrap(textView, scrollView)
        textView.delegate = context.coordinator

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let fileBuffer = state.fileBuffer else { return }

        //print("nsview updated: \(fileBuffer.name), TextBufferEditor, updateNSView")

        // LogStore @Observable 이라; 여기서 쓰면 View 삭제될 때 무한 루프 생긴다;
        // let log = LogStore.shared.log

        if fileBuffer.shouldTextViewCopyOriginalText {
            guard let textView = nsView.documentView as? NSTextView else { return }
            textView.string = fileBuffer.originalText
            fileBuffer.textView = textView
            fileBuffer.shouldTextViewCopyOriginalText = false
        }
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

        textView.allowsUndo = true

        textView.usesFindBar = true
        //textView.usesFindPanel = true

        // 이 기능은 고장나있다.
        // 기능하게 하려면 꽤 코딩이 필요할 듯. 일단 쓰지 않는 것으로.
        textView.isIncrementalSearchingEnabled = false

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

    final class Coordinator: NSObject, NSTextViewDelegate {
        let appState: AppState
        let state: FileBrowserState

        init(_ view: TextBufferEditor) {
            //print("coordinator created: \(view.state.id), TextBufferEditor.Coordinator")
            appState = view.appState
            state = view.state
        }

        func textDidChange(_ notification: Notification) {
            guard let fileBuffer = state.fileBuffer else { return }

            //print("text changed: \(fileBuffer.name), TextBufferEditor.Coordinator")
            // guard let textView = notification.object as? NSTextView else { return }

            fileBuffer.isTextViewEdited = true
            if appState.isAutoSaveEnabled {
                fileBuffer.scheduleAutoSave(after: appState.autoSaveDelay)
            }
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if appState.tabKeyAction == .indentWithSpace {
                if commandSelector == #selector(NSResponder.insertTab(_:)) {
                    indentSelection(textView)
                    return true
                }

                if commandSelector == #selector(NSResponder.insertBacktab(_:)) {
                    outdentSelection(textView)
                    return true
                }
            }

            return false
        }

        private func indentSelection(_ textView: NSTextView) {
            guard let undoManager = textView.undoManager else { return }
            guard let textStorage = textView.textStorage else { return }
            let selectedRange = textView.selectedRange()
            var newRange = selectedRange
            let nsString = textStorage.string as NSString
            let fullLineRange = nsString.lineRange(for: selectedRange)
            let indentSize = appState.indentSize
            let spaces = String(repeating: " ", count: indentSize)

            undoManager.beginUndoGrouping()
            undoManager.registerUndo(withTarget: textView) { target in
                target.setSelectedRange(selectedRange)
            }
            if textView.shouldChangeText(in: fullLineRange, replacementString: nil) {
                textStorage.beginEditing()
                nsString.enumerateSubstrings(in: fullLineRange, options: [.byLines, .substringNotRequired]) { _, lineRange, _, _ in
                    let insertRange = NSRange(location: lineRange.location, length: 0)
                    textStorage.replaceCharacters(in: insertRange, with: spaces)
                    undoManager.registerUndo(withTarget: textView) { target in
                        let removeRange = NSRange(location: lineRange.location, length: indentSize)
                        target.textStorage?.replaceCharacters(in: removeRange, with: "")
                    }
                    if lineRange.location <= newRange.location {
                        newRange.location += indentSize
                    } else if lineRange.location < newRange.location + newRange.length {
                        newRange.length += indentSize
                    }
                }
                textStorage.endEditing()
                textView.didChangeText()
            }
            textView.setSelectedRange(newRange)
            undoManager.endUndoGrouping()
            undoManager.setActionName("Indent")
        }

        private func outdentSelection(_ textView: NSTextView) {
            guard let undoManager = textView.undoManager else { return }
            guard let textStorage = textView.textStorage else { return }
            let selectedRange = textView.selectedRange()
            var newRange = selectedRange
            let nsString = textStorage.string as NSString
            let fullLineRange = nsString.lineRange(for: selectedRange)
            let indentSize = appState.indentSize

            undoManager.beginUndoGrouping()
            undoManager.registerUndo(withTarget: textView) { target in
                target.setSelectedRange(selectedRange)
            }
            if textView.shouldChangeText(in: fullLineRange, replacementString: nil) {
                textStorage.beginEditing()
                nsString.enumerateSubstrings(in: fullLineRange, options: [.byLines, .substringNotRequired]) { _, lineRange, _, _ in
                    var spaceCount = 0
                    for i in 0..<indentSize {
                        let char = nsString.character(at: lineRange.location + i)
                        if char == 32 {
                            spaceCount += 1
                        } else {
                            break
                        }
                    }
                    if spaceCount > 0 {
                        let removeRange = NSRange(location: lineRange.location, length: spaceCount)
                        textStorage.replaceCharacters(in: removeRange, with: "")
                        undoManager.registerUndo(withTarget: textView) { target in
                            let insertRange = NSRange(location: lineRange.location, length: 0)
                            let spaces = String(repeating: " ", count: spaceCount)
                            target.textStorage?.replaceCharacters(in: insertRange, with: spaces)
                        }
                    }
                    if lineRange.location <= newRange.location - spaceCount {
                        newRange.location -= spaceCount
                    } else if lineRange.location <= newRange.location {
                        newRange.length -= lineRange.location + spaceCount - newRange.location
                        newRange.location = lineRange.location
                        if newRange.length < 0 {
                            newRange.length = 0
                        }
                    } else if lineRange.location <= newRange.location + newRange.length - spaceCount{
                        newRange.length -= spaceCount
                    } else if lineRange.location <= newRange.location + newRange.length {
                        newRange.length = lineRange.location - newRange.location
                    }
                }
                textStorage.endEditing()
                textView.didChangeText()
            }
            textView.setSelectedRange(newRange)
            undoManager.endUndoGrouping()
            undoManager.setActionName("Unindent")
        }
    }

}
