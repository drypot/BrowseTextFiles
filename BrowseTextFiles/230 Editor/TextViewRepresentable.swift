//
//  TextViewRepresentable.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/26/25.
//

import SwiftUI

// https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextEditing/TextEditing.html#//apple_ref/doc/uid/TP40009459-CH3-SW16

struct TextViewRepresentable: NSViewRepresentable {
    @Environment(AppState.self) var appState
    @Environment(EditorState.self) var editorState

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        consoleLog("make nstextview:")

        let textView = makeTextView()
        let scrollView = makeScrollView(for: textView)
        // configureForNoWrap(textView, scrollView)
        textView.delegate = context.coordinator
        editorState.textView = textView

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        //print("nsview updated: \(fileBuffer.name), TextBufferEditor, updateNSView")
        // LogStore @Observable 이라; 여기서 쓰면 View 삭제될 때 무한 루프 생긴다;

        if editorState.shouldCopyOriginalText {
            guard let textView = nsView.documentView as? NSTextView else { return }
            textView.string = editorState.originalText
            editorState.shouldCopyOriginalText = false
            editorState.updateTextViewStyleCount += 1
        }
    }

    func makeTextView() -> NSTextView {
        let textView = NSTextView()

        textView.autoresizingMask = [.width, .height] // 필수다.
        textView.textContainerInset = NSSize(width: 16, height: 8) // 패딩

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

        // textView.appearance = NSApp.effectiveAppearance
        // textView.wantsLayer = true
        // textView.textColor = .textColor
        // textView.backgroundColor = .textBackgroundColor
        textView.drawsBackground = false // dark mode 대응

        // 사용자 입력에 따라 컨트롤이 계속 커지게 만들려면 true.
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false // **
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        //        if let layoutManager = textView.textLayoutManager {
        //            if let textContainer = layoutManager.textContainer {
        //                // Wrap 모드면 true
        //                textContainer.widthTracksTextView = true // **
        //                textContainer.size = NSSize(
        //                    width: CGFloat.greatestFiniteMagnitude,
        //                    height: CGFloat.greatestFiniteMagnitude
        //                )
        //            }
        //        }

        return textView
    }

    // 전에 쓰던 코드인데 NSTextView 생성을 괜히 일만들어 하는 것 같아서;
    // 새로운 makeTextView() 로 단순화 했다;
    // 혹시 다시 필요할까 싶어 그냥 둔다;
    func makeTextViewV1() -> NSTextView {
        let contentStorage = NSTextContentStorage()

        let layoutManager = NSTextLayoutManager()
        contentStorage.addTextLayoutManager(layoutManager)

        let textContainer = NSTextContainer()
        layoutManager.textContainer = textContainer

        let textView = NSTextView(frame: .zero, textContainer: textContainer)

        textView.autoresizingMask = [.width, .height] // 필수다.
        textView.textContainerInset = NSSize(width: 16, height: 8) // 패딩

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

        // textView.appearance = NSApp.effectiveAppearance
        // textView.wantsLayer = true
        // textView.textColor = .textColor
        // textView.backgroundColor = .textBackgroundColor
        textView.drawsBackground = false // dark mode 대응

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

        //textView 에서 줬다.
        //scrollView.contentInsets = NSEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //scrollView.automaticallyAdjustsContentInsets = false

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
        let editorState: EditorState

        init(_ view: TextViewRepresentable) {
            //print("coordinator created: \(view.stateRoot.id), TextBufferEditor.Coordinator")
            appState = view.appState
            editorState = view.editorState
        }

        func textDidChange(_ notification: Notification) {
            //print("text changed: \(editorState.editingFilename)")
            //guard let textView = notification.object as? NSTextView else { return }

            editorState.isTextViewEdited = true
            if appState.isAutoSaveEnabled {
                editorState.scheduleAutoSave(after: appState.autoSaveDelay)
            }
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if appState.tabKeyAction == .indentWithSpace {
                if commandSelector == #selector(NSResponder.insertTab(_:)) {
                    indentWithSpace(textView)
                    return true
                }

                if commandSelector == #selector(NSResponder.insertBacktab(_:)) {
                    outdentWithSpace(textView)
                    return true
                }
            }

            return false
        }

        func updateTextView(_ textView: NSTextView,
                            in oldRange: NSRange,
                            with newText: String,
                            newSelectedRange: NSRange) {

            guard let undoManager = textView.undoManager else { return }
            guard let textStorage = textView.textStorage else { return }
            let oldText = textStorage.attributedSubstring(from: oldRange).string
            let oldSelectedRange = textView.selectedRange()
            let newNSText = newText as NSString
            let newRange = NSRange(location: oldRange.location, length: newNSText.length)

            undoManager.registerUndo(withTarget: self) { target in
                target.updateTextView(textView,
                                      in: newRange,
                                      with: oldText,
                                      newSelectedRange: oldSelectedRange)
            }

            textStorage.beginEditing()
            textStorage.replaceCharacters(in: oldRange, with: newText)
            textStorage.endEditing()

            textView.setSelectedRange(newSelectedRange)
        }

        private func indentWithSpace(_ textView: NSTextView) {
            guard let undoManager = textView.undoManager else { return }
            guard let textStorage = textView.textStorage else { return }
            let selectedRange = textView.selectedRange()
            var newSelectedRange = selectedRange
            let nsString = textStorage.string as NSString
            let totalLineRange = nsString.lineRange(for: selectedRange)
            let indentSize = appState.indentSize
            let spaces = String(repeating: " ", count: indentSize)

            var resultLines: [String] = []
            var delta = 0

            if selectedRange.length == 0 {
                let lineRange = nsString.lineRange(for: selectedRange)
                let line = spaces + nsString.substring(with: lineRange)
                resultLines.append(line)
                delta += indentSize
            } else {
                var lineHead = NSRange(location: totalLineRange.location, length: 0)
                while lineHead.location < NSMaxRange(totalLineRange) {
                    let lineRange = nsString.lineRange(for: lineHead)
                    let line = spaces + nsString.substring(with: lineRange)
                    resultLines.append(line)
                    delta += indentSize
                    lineHead.location = NSMaxRange(lineRange)
                }
            }

            let replacement = resultLines.joined()

            newSelectedRange.location += indentSize
            newSelectedRange.length += delta - indentSize

            undoManager.beginUndoGrouping()
            //if textView.shouldChangeText(in: lineRange, replacementString: replacement) {
            //    textView.didChangeText()
            //}
            updateTextView(textView, in: totalLineRange, with: replacement, newSelectedRange: newSelectedRange)
            undoManager.endUndoGrouping()
            undoManager.setActionName("Indent")
        }

        private func outdentWithSpace(_ textView: NSTextView) {
            guard let undoManager = textView.undoManager else { return }
            guard let textStorage = textView.textStorage else { return }
            let selectedRange = textView.selectedRange()
            var newSelectedRange = selectedRange
            let nsString = textStorage.string as NSString
            let totalLineRange = nsString.lineRange(for: selectedRange)
            let indentSize = appState.indentSize

            var resultLines: [String] = []
            var isFirstLine = true
            var firstLineDelta = 0
            var delta = 0

            var lineHead = NSRange(location: totalLineRange.location, length: 0)
            while lineHead.location < NSMaxRange(totalLineRange) {
                let lineRange = nsString.lineRange(for: lineHead)

                var spaceCount = 0
                for i in 0..<indentSize {
                    let char = nsString.character(at: lineRange.location + i)
                    if char == 32 {
                        spaceCount += 1
                    } else {
                        break
                    }
                }

                let copyRange = NSRange(location: lineRange.location + spaceCount,
                                        length: lineRange.length - spaceCount)
                let line = nsString.substring(with: copyRange)
                resultLines.append(line)

                if isFirstLine {
                    firstLineDelta = spaceCount
                    isFirstLine = false
                } else {
                    delta += spaceCount
                }

                lineHead.location = NSMaxRange(lineRange)
            }

            let replacement = resultLines.joined()

            newSelectedRange.location -= firstLineDelta
            newSelectedRange.length -= delta
            if totalLineRange.location > newSelectedRange.location {
                let alpha = totalLineRange.location - newSelectedRange.location
                newSelectedRange.location += alpha
                if newSelectedRange.length >= alpha {
                    newSelectedRange.length -= alpha
                }
            }

            undoManager.beginUndoGrouping()
            //if textView.shouldChangeText(in: lineRange, replacementString: replacement) {
            //    textView.didChangeText()
            //}
            updateTextView(textView, in: totalLineRange, with: replacement, newSelectedRange: newSelectedRange)
            undoManager.endUndoGrouping()
            undoManager.setActionName("Unindent")
        }
    }

}
